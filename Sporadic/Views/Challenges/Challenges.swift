//
//  Challenges.swift
//  Sporadic
//
//  Created by Brendan Perry on 5/29/22.
//

import SwiftUI
import CloudKit
import ConfettiSwiftUI
import Combine
import OneSignalFramework
import StoreKit
import WidgetKit

struct Challenges: View {
    let challenges: [Challenge]
    let isLoading: Bool
    let triggerConfetti: (UserGroup) -> Void
    
    var body: some View {
        VStack {
            TextHelper.text(key: "Challenges", alignment: .leading, type: .h4)
                .padding(.horizontal)
            
            VStack {
                if isLoading && challenges.isEmpty {
                    ChallengeLoading()
                }
                else {
                    ForEach(challenges) { challenge in
                        ChallengeView(challenge: challenge, triggerConfetti: triggerConfetti, showNavigationCarrot: false)
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct ChallengeLoading: View {
    @State var isAnimating = false
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(.white)
                .frame(width: 35, alignment: .center)
                .padding(.trailing, 5)
            
            LoadingBar()
                .frame(height: 20)
        }
        .padding()
        .frame(height: 75, alignment: .center)
        .background(LinearGradient(gradient: Gradient(colors: [Color("Gradient1"), Color("Gradient2")]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(10)
        .shadow(color: Color("Shadow"), radius: 16, x: 0, y: 4)
        .padding(.horizontal)
        .padding(.top, 5)
    }
}

struct ChallengeView: View {
    @ObservedObject var challenge: Challenge
    @Environment(\.requestReview) var requestReview
    @State var showError = false
    let triggerConfetti: (UserGroup) -> Void
    let showNavigationCarrot: Bool
    
    var body: some View {
        HStack {
            HStack {
                switch challenge.status {
                case .inProgress:
                    inProgressCheckbox()
                case .userCompleted:
                    completedCheckbox()
                case .groupCompleted:
                    completedCheckbox()
                case .failed:
                    failedCheckbox()
                case .unknown:
                    EmptyView()
                }
                
                VStack(spacing: 0) {
                    getChallengeText()
                    TextHelper.text(key: "\(challenge.group?.name ?? "")", alignment: .leading, type: .h6, color: Color("BrandLight"))
                    UserList(users: challenge.users ?? [], challenge: challenge)
                        .padding(.top, 5)
                }
            }
            .padding()
            
            if challenge.status == .inProgress || challenge.status == .userCompleted {
                DueTime(challenge: challenge)
                    .transition(.move(edge: .trailing))
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color("Gradient1"), Color("Gradient2")]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
        .padding(.horizontal)
        .padding(.top, 5)
        .alert(isPresented: $showError) {
            Alert(title: Text("Oh no!"), message: Text("This exercise could not be completed due to a connection problem. Please check your internet connection and try again."))
        }
    }
    
    func getChallengeText() -> some View {
        if challenge.unit == .reps {
            return TextHelper.text(key: "Do \(challenge.amount.formatted(FloatingPointFormatStyle())) \(challenge.activityName)", alignment: .leading, type: .h3, color: .white)
        }
        else if challenge.unit == .miles || challenge.unit == .laps {
            return TextHelper.text(key: "\(challenge.activityName) \(challenge.amount.formatted(FloatingPointFormatStyle())) \(challenge.getLabel())", alignment: .leading, type: .h3, color: .white)
        }
        else if challenge.unit == .seconds || challenge.unit == .minutes {
            return TextHelper.text(key: "\(challenge.activityName) for \(challenge.amount.formatted(FloatingPointFormatStyle())) \(challenge.getLabel())", alignment: .leading, type: .h3, color: .white)
        }
        else {
            return TextHelper.text(key: "\(challenge.activityName) \(challenge.amount.formatted(FloatingPointFormatStyle())) \(challenge.getLabel())", alignment: .leading, type: .h3, color: .white)
        }
    }
    
    struct DueTime: View {
        @ObservedObject var challenge: Challenge
        @State var timeRemaining = "00:00"
        let timer = Timer.publish(every: 60, tolerance: 10, on: .main, in: .common).autoconnect()
        
        var body: some View {
            VStack {
                TextHelper.text(key: timeRemaining, alignment: .center, type: .h6, color: .white)
            }
            .frame(maxWidth: 75, maxHeight: .infinity)
            .background(Color("Gray50"))
            .cornerRadius(GlobalSettings.shared.controlCornerRadius, corners: [.topRight, .bottomRight])
            .onReceive(timer) { _ in
                updateTimeTillDue()
            }
            .onAppear {
                updateTimeTillDue()
            }
        }
        
        func updateTimeTillDue() {
            challenge.setStatus()
            
            if let endTime = Calendar.current.date(byAdding: .day, value: 1, to: challenge.startTime) {
                let timeLeft = endTime.timeIntervalSince1970 - Date().timeIntervalSince1970
                let hours = Int(timeLeft) / 3600
                
                let secondsLeftAfterHoursTakenOut = Int(timeLeft) - (hours * 3600)
                
                let minutes = secondsLeftAfterHoursTakenOut / 60
                
                if minutes > 9 {
                    timeRemaining = "\(hours):\(minutes)"
                }
                else {
                    timeRemaining = "\(hours):0\(minutes)"
                }
            }
        }
    }
    
    func inProgressCheckbox() -> some View {
        Button(action: {
            guard let user = CloudKitHelper.shared.getCachedUser() else {
                return
            }
            
            let currentStatus = challenge.status
            let currentUsersCompleted = challenge.usersCompleted
            
            if currentStatus == .inProgress {
                withAnimation {
                    if challenge.users?.count == challenge.usersCompleted.count + 1 {
                        challenge.status = .groupCompleted
                        challenge.cachedStatus = .groupCompleted
                    }
                    else {
                        challenge.status = .userCompleted
                        challenge.cachedStatus = .userCompleted
                    }
                    
                    challenge.usersCompleted.append(user)
                    
                    if let group = challenge.group {
                        triggerConfetti(group)
                    }
                }
            }
            
            CloudKitHelper.shared.completeChallenge(challenge: challenge) { error in
                if let error = error {
                    print(error)
                    showError = true
                    challenge.status = currentStatus
                    challenge.cachedStatus = .unknown
                    challenge.usersCompleted = currentUsersCompleted
                }
                else {
                    Task {
                        try? await CloudKitHelper.shared.sendUsersNotifications(challenge: challenge)
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    
                    showReviewPopUp()
                }
            }
        }, label: {
            Image("Unmarked Challenge Icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 35, height: 35, alignment: .center)
        })
        .padding(.trailing, 5)
    }
    
    func showReviewPopUp() {
        let challengesCompleted = UserDefaults.standard.integer(forKey: "ChallengesCompleted")
        
        if challengesCompleted == 1 {
            requestReview()
        }
        else if challengesCompleted % 30 == 0 && challengesCompleted != 0 {
            requestReview()
        }
        
        UserDefaults.standard.set(challengesCompleted + 1, forKey: "ChallengesCompleted")
    }
    
    func completedCheckbox() -> some View {
        Image("Completed Challenge Icon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(width: 35, height: 35, alignment: .center)
            .padding(.trailing, 5)
    }
    
    func failedCheckbox() -> some View {
        Image("Failed Challenge Icon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(width: 35, height: 35, alignment: .center)
            .padding(.trailing, 5)
    }
    
    struct UserList: View {
        let users: [User]
        @ObservedObject var challenge: Challenge
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(users.sorted(by: { $0.name < $1.name })) { user in
                        if user.usersRecordId != CloudKitHelper.shared.getCachedUser()?.usersRecordId {
                            ZStack {
                                Circle()
                                    .foregroundColor(challenge.usersCompleted.contains(where: { $0.record.recordID == user.record.recordID }) ? Color("SuccessButtons") : .clear)
                                    .frame(width: 33, height: 33)
                                
                                Image(uiImage: user.photo ?? UIImage(named: "Default Profile")!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(.infinity)
                                    .opacity(challenge.usersCompleted.contains(where: { $0.record.recordID == user.record.recordID }) ? 1 : 0.5)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
