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
import OneSignal

struct Challenges: View {
    let challenges: [Challenge]
    let isLoading: Bool
    let triggerConfetti: (UserGroup) -> Void
    
    var body: some View {
        VStack {
            TextHelper.text(key: "Challenges", alignment: .leading, type: .h4, color: .primary)
                .padding(.horizontal)
            
            VStack {
                if isLoading && challenges.isEmpty {
                    ChallengeLoading()
                }
                else {
                    if challenges.isEmpty {
                        TextHelper.text(key: "No challenges yet today!", alignment: .center, type: .body)
                            .padding(.top)
                    }
                    else {
                        ForEach(challenges) { challenge in
                            ChallengeView(challenge: challenge, triggerConfetti: triggerConfetti, showNavigationCarrot: false)
                        }
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
        .shadow(radius: 3)
        .padding(.horizontal)
        .padding(.top, 5)
    }
}

struct ChallengeView: View {
    @ObservedObject var challenge: Challenge
    @State var showError = false
    let triggerConfetti: (UserGroup) -> Void
    let showNavigationCarrot: Bool
    
    var body: some View {
        HStack {
            HStack {
                switch challenge.status {
                case .inProgress:
                    inProgressCheckbox()
                    
                    VStack(spacing: 0) {
                        getChallengeText()
                        TextHelper.text(key: "\(challenge.group?.name ?? "")", alignment: .leading, type: .h6)
                        UserList(users: challenge.users ?? [], challenge: challenge)
                            .padding(.top, 5)
                    }
                case .userCompleted:
                    completedCheckbox()
                    
                    VStack(spacing: 0) {
                        getChallengeText()
                        TextHelper.text(key: "\(challenge.group?.name ?? "")", alignment: .leading, type: .h6)
                        UserList(users: challenge.users ?? [], challenge: challenge)
                            .padding(.top, 5)
                    }
                case .groupCompleted:
                    completedCheckbox()
                    
                    VStack(spacing: 0) {
                        TextHelper.text(key: "ChallengeCompleted", alignment: .leading, type: .h3, color: .white)
                        TextHelper.text(key: "\(challenge.group?.name ?? "")", alignment: .leading, type: .h6)
                        UserList(users: challenge.users ?? [], challenge: challenge)
                            .padding(.top, 5)
                    }
                case .failed:
                    failedCheckbox()
                    
                    VStack(spacing: 0) {
                        TextHelper.text(key: "ChallengeFailed", alignment: .leading, type: .h3, color: .white)
                        TextHelper.text(key: "\(challenge.group?.name ?? "")", alignment: .leading, type: .h6)
                        UserList(users: challenge.users ?? [], challenge: challenge)
                            .padding(.top, 5)
                    }
                case .unknown:
                    VStack(spacing: 0) {
                        TextHelper.text(key: "", alignment: .leading, type: .h3, color: .white)
                        TextHelper.text(key: "\(challenge.group?.name ?? "")", alignment: .leading, type: .h6)
                        UserList(users: challenge.users ?? [], challenge: challenge)
                            .padding(.top, 5)
                    }
                }
            }
            .padding()
            
            if challenge.status == .inProgress || challenge.status == .userCompleted {
                DueTime(challengeStartTime: challenge.startTime)
                    .transition(.move(edge: .trailing))
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color("Gradient1"), Color("Gradient2")]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(GlobalSettings.shared.controlCornerRadius)
        .shadow(radius: 3)
        .padding(.horizontal)
        .padding(.top, 5)
        .alert(isPresented: $showError) {
            Alert(title: Text("Connection Failed"), message: Text("Could not complete exercise."))
        }
    }
    
    func getChallengeText() -> some View {
        if challenge.activity?.unit == .reps {
            return TextHelper.text(key: "Do \(challenge.amount.formatted(FloatingPointFormatStyle())) \(getLabel(challenge.amount, challenge.activity?.name ?? ""))", alignment: .leading, type: .h3, color: .white)
        }
        else if challenge.activity?.unit == .miles || challenge.activity?.unit == .laps {
            return TextHelper.text(key: "\(challenge.activity?.name ?? "") \(challenge.amount.formatted(FloatingPointFormatStyle())) \(getLabel(challenge.amount, challenge.activity?.unit.rawValue ?? ""))", alignment: .leading, type: .h3, color: .white)
        }
        else if challenge.activity?.unit == .seconds || challenge.activity?.unit == .minutes {
            return TextHelper.text(key: "\(challenge.activity?.name ?? "") for \(challenge.amount.formatted(FloatingPointFormatStyle())) \(getLabel(challenge.amount, challenge.activity?.unit.rawValue  ?? ""))", alignment: .leading, type: .h3, color: .white)
        }
        else {
            return TextHelper.text(key: "\(challenge.activity?.name ?? "") \(challenge.amount.formatted(FloatingPointFormatStyle())) \(getLabel(challenge.amount, challenge.activity?.unit.rawValue  ?? ""))", alignment: .leading, type: .h3, color: .white)
        }
    }
    
    func getLabel(_ amount: Double, _ unit: String) -> String {
        var unit = unit
        if amount == 1 {
            if unit.last == "s" {
                let _ = unit.popLast()
            }
        }
        
        return unit
    }
    
    struct DueTime: View {
        let challengeStartTime: Date
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
            if let endTime = Calendar.current.date(byAdding: .day, value: 1, to: challengeStartTime) {
                let timeLeft = endTime.timeIntervalSince1970 - Date().timeIntervalSince1970
                let hours = Int(timeLeft) / 3600
                
                let secondsLeftAfterHoursTakenOut = Int(timeLeft) - (hours * 3600)
                
                let minutes = secondsLeftAfterHoursTakenOut / 60
                
                if minutes > 10 {
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
                    }
                    else {
                        challenge.status = .userCompleted
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
                    challenge.usersCompleted = currentUsersCompleted
                }
                else {
                    Task {
                        try? await CloudKitHelper.shared.sendUsersNotifications(challenge: challenge)
                    }
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
            ScrollView(.horizontal) {
                HStack {
                    ForEach(users.sorted(by: { $0.name < $1.name })) { user in
                        Image(uiImage: user.photo ?? UIImage(named: "defaultProfile")!)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(.infinity)
                            .opacity(challenge.usersCompleted.contains(where: { $0.record.recordID == user.record.recordID }) ? 1 : 0.5)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
