//
//  MainView.swift
//  Sporadic
//
//  Created by Brendan Perry on 7/2/21.
//

import SwiftUI
import HealthKit

struct MainView: View {
    @StateObject var viewRouter = ViewRouter()
    
    @State var selectedTab = 0
    @State var isAdding = false
    @State var healthIsNotAvailable = true
    @State var isHealthKitAuthorized = false
    @State var workouts: [HKWorkout]?
    
    @AppStorage(UserPrefs.appearance.rawValue)
    var appTheme = "System"
    
    let healthKitHelper = HealthKitHelper()
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var activities: FetchedResults<Activity>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                switch viewRouter.currentPage {
                case .home:
                    HomePage(isAdding: $isAdding)
                case .settings:
                    SettingsPage()
                case .tutorial:
                    Text("Tutorial")
                }
                
                if (isAdding) {
                    AddPage(isAdding: $isAdding)
                }
                
                NavigationBar(isAdding: self.$isAdding)
            }
            .environmentObject(viewRouter)
            .fullScreenCover(isPresented: $isHealthKitAuthorized) {
                VStack {
                    Text("Loading your health")
                    
                    if let workouts = workouts {
                        if workouts.isEmpty {
                            Text("No workouts found. Make sure you have given Sporadic access in the Health app!")
                        } else {
                            List(workouts, id: \.uuid) { workout in
                                Text("\(workout.workoutActivityType.rawValue) > \(workout.totalDistance!)")
                            }
                        }
                    }
                    
                    //CompleteChallenges()
                        
                    Button("Done!") {
                        isHealthKitAuthorized = false
                    }.padding()
                }
            }
            .onAppear {
                authorizeHealthKit()
                        
                UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
                    if (notifications.count == 0) {
                        let notificationHelper = NotificationHelper(context: DataController.shared.controller.viewContext)

                        notificationHelper.scheduleAllNotifications()
                    }
                }
            }
        }
    }
    
    func authorizeHealthKit() {
        healthKitHelper.authorizeHealthKit { success in
            if (success) {
                isHealthKitAuthorized = true
                healthKitHelper.getSamples(for: HKWorkoutActivityType.running) { samples, error in
                    if let error = error {
                        print("Error: \(error)")
                    } else {
                        workouts = samples
                    }
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
