//
//  ContentView.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI
import UserNotifications

struct HomePage: View {
    @StateObject var viewModel = ActivityViewModel()
    @State private var selected = 0;

    var body: some View {
        ZStack {
            TabView {
                MainView()
                    .tabItem {
                        Image(systemName: "house")
                    }
                Settings()
                    .tabItem {
                        Image(systemName: "gear")
                    }
            }
        }
        .environmentObject(viewModel)
    }
}

struct Settings: View {
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Settings")
                Button(action: {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("All set!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }, label: {
                    Text("Request Notification Access")
                })
            }
        }
    }
}

struct MainView: View {
    var body: some View {
        ZStack {
            Image("BackgroundImage")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack {
                    Welcome()
                    ChallengeButton()
                    Streak()
                    Activities()
                    DeliveryTime()
                    Spacer()
                }
            })
            .padding(.top)
        }
    }
}

struct Welcome: View {
    var body: some View {
        VStack {
            Text(Localize.getString("WelcomeBack"))
                .foregroundColor(Color("SubHeadingColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Font.custom("Gilroy-Medium", size: 18))
            Text(Localize.getString("YourGoal"))
                .font(.title)
                .fontWeight(.bold)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .font(Font.custom("Gilroy", size: 18))
        }
        .padding(.horizontal)
        .padding(.top, 50)
        .padding(.bottom)
    }
}

struct ChallengeButton: View {
    //var viewModel: ActivityViewModel
    @State private var activityCompleted = false
    
    var body: some View {
        VStack {
            Button(action: {
                print("done")
                
                activityCompleted = true
            }) {
                ZStack {
                    Image("GoalButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 325)
                    HStack {
//                        Checkmark(size: 30, isOn: activityCompleted, activity: <#Activity#>, viewModel: viewModel)
                        Text("Run 3 miles")
                            .font(.title)
                            .bold()
                    }
                    .offset(y: -7)
                }
                
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .disabled(activityCompleted)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct Streak: View {
    var body: some View {
        VStack {
            Text(Localize.getString("CurrentRhythm"))
                .font(.footnote)
                .bold()
                .foregroundColor(Color("SubHeadingColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Font.custom("Gilroy-Medium", size: 18))
            Text("16 days!")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
        }
        .padding()
    }
}

struct Activities: View {
    @EnvironmentObject var viewModel: ActivityViewModel
    
    var body: some View {
        VStack {
            Text(Localize.getString("Activities"))
                .font(.footnote)
                .bold()
                .foregroundColor(Color("SubHeadingColor"))
                .font(Font.custom("Gilroy-Medium", size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding(.top)
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack {
                    ForEach(viewModel.activities) { activity in
                        ActivityWidget(activity: activity)
                    }
                }
            })
        }
    }
}

struct DeliveryTime: View {
    var body: some View {
        VStack {
            Text(Localize.getString("RandomNotificationDelivery"))
                .bold()
                .foregroundColor(Color("SubHeadingColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("3 days a week,\ndelivered at 6:00am.")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: {
                print("edit")
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color("ActivityBackgroundColor"))
                        .frame(width: 100, height: 35)
                        .offset(x: 5, y: 5)
                    Text("Edit")
                        .foregroundColor(Color("BlackWhiteColor"))
                        .bold()
                        .frame(width: 100, height: 35)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 3)
                            .foregroundColor(.blue)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
        }
        .padding()
    }
}

struct ActivityWidget: View {
    var activity: Activity
    @EnvironmentObject var viewModel: ActivityViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color("ActivityBackgroundColor"))
                .frame(width: 120, height: 180)
                .offset(x: 10, y: 10)
            VStack {
                CustomSVG(name: activity.name, tintColor: UIColor(hexaRGB: "#4776EB")!)
                    .frame(width: 50, height: 50)
                Text(activity.name)
                    .bold()
                Text("\(activity.minValue, specifier: "%.1f")-\(activity.maxValue, specifier: "%.1f")mi")
                    .font(.footnote)
                    .bold()
                    .foregroundColor(Color("ActivityRangeColor"))
                    .padding(.top, 5)
                Checkmark(size: 25, isOn: activity.isEnabled, activity: activity)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 25)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                .stroke(lineWidth: 5)
                .foregroundColor(Color("ActivityBorderColor"))
            )
            .padding()
        }
    }
}

struct Checkmark: View {
    var size: CGFloat
    var isOn: Bool
    var activity: Activity
    @EnvironmentObject var viewModel: ActivityViewModel
    
    var body: some View {
        if isOn {
            Button(action: {
                viewModel.activityCheckmarkClicked(id: activity.id, isOn: !isOn)
            }, label: {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 5)
                        .frame(width: size, height: size)
                        .foregroundColor(Color("CheckGreen"))
                    Circle()
                        .frame(width: size, height: size)
                        .foregroundColor(Color("CheckGreen"))
                    CustomSVG(name: "Checkmark", tintColor: UIColor.white)
                        .frame(width: size + 20, height: size + 20)
                }
            })
        } else {
            Button(action: {
                viewModel.activityCheckmarkClicked(id: activity.id, isOn: !isOn)
            }, label: {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 5)
                        .frame(width: size, height: size)
                        .foregroundColor(Color("CheckGreen"))
                    CustomSVG(name: "Checkmark", tintColor: UIColor.white.withAlphaComponent(0))
                        .frame(width: size + 20, height: size + 20)
                }
            })
        }
    }
}

struct CustomSVG: UIViewRepresentable {
  var name: String
  var contentMode: UIView.ContentMode = .scaleAspectFit
  var tintColor: UIColor = .black

  func makeUIView(context: Context) -> UIImageView {
    let imageView = UIImageView()
    imageView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
    return imageView
  }

  func updateUIView(_ uiView: UIImageView, context: Context) {
    uiView.contentMode = contentMode
    uiView.tintColor = tintColor
    if let image = UIImage(named: name) {
      uiView.image = image
    }
  }
}

extension UIColor {
    convenience init?(hexaRGB: String, alpha: CGFloat = 1) {
        var chars = Array(hexaRGB.hasPrefix("#") ? hexaRGB.dropFirst() : hexaRGB[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }
        case 6: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                alpha: alpha)
    }

    convenience init?(hexaRGBA: String) {
        var chars = Array(hexaRGBA.hasPrefix("#") ? hexaRGBA.dropFirst() : hexaRGBA[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }; fallthrough
        case 6: chars.append(contentsOf: ["F","F"])
        case 8: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                alpha: .init(strtoul(String(chars[6...7]), nil, 16)) / 255)
    }

    convenience init?(hexaARGB: String) {
        var chars = Array(hexaARGB.hasPrefix("#") ? hexaARGB.dropFirst() : hexaARGB[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }; fallthrough
        case 6: chars.append(contentsOf: ["F","F"])
        case 8: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[6...7]), nil, 16)) / 255,
                alpha: .init(strtoul(String(chars[0...1]), nil, 16)) / 255)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomePage().preferredColorScheme(.light)
    }
}
