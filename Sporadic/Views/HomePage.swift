//
//  ContentView.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI
import UserNotifications

struct HomePage: View {    
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
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 100, height: 100, alignment: .bottom)
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
                .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .footnote))
            Text(Localize.getString("YourGoal"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .font(Font.custom("Gilroy", size: 38, relativeTo: .largeTitle))
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
                            .font(Font.custom("Gilroy", size: 32, relativeTo: .title))
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
                .foregroundColor(Color("SubHeadingColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .footnote))
            Text("16 days!")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Font.custom("Gilroy", size: 38, relativeTo: .largeTitle))
        }
        .padding()
    }
}

struct Activities: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel
    
    var body: some View {
        VStack {
            Text(Localize.getString("Activities"))
                .foregroundColor(Color("SubHeadingColor"))
                .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .footnote))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding(.top)
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack {
                    ForEach(activityViewModel.activities) { activity in
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
                .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .footnote))
                .foregroundColor(Color("SubHeadingColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("3 days a week,\ndelivered at 6:00am.")
                .font(Font.custom("Gilroy", size: 30, relativeTo: .title))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
//            Button(action: {
//                print("edit")
//            }) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 15, style: .continuous)
//                        .fill(Color("ActivityBackgroundColor"))
//                        .frame(width: 100, height: 35)
//                        .offset(x: 5, y: 5)
//                    Text("Edit")
//                        .foregroundColor(Color("BlackWhiteColor"))
//                        .bold()
//                        .frame(width: 100, height: 35)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 15)
//                            .stroke(lineWidth: 3)
//                            .foregroundColor(.blue)
//                        )
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
            
        }
        .padding()
    }
}

struct ActivityWidget: View {
    var activity: Activity
    @EnvironmentObject var activityViewModel: ActivityViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("ActivityBackgroundColor"))
                .frame(width: 170, height: 210)
                .offset(x: 15, y: 15)
            Button(action: {
                
            }, label: {
                Image("Bike")
            })
            .offset(x: 50, y: -70)
            VStack {
                CustomSVG(name: activity.name, size: 50, tintColor: UIColor(hexaRGB: "#4146E3")!)
                    .frame(width: 50, height: 50)
                Text(activity.name)
                    .font(Font.custom("Gilroy", size: 30, relativeTo: .title))
                    .padding(.top, -1)
                HStack (spacing: 0) {
                    Text("\(activity.minValue, specifier: "%.1f")-\(activity.maxValue, specifier: "%.1f")")
                        .foregroundColor(Color("ActivityRangeColor"))
                        .font(Font.custom("Gilroy", size: 19, relativeTo: .body))
                    Text("mi")
                        .foregroundColor(Color("ActivityRangeColor"))
                        .font(Font.custom("Gilroy", size: 13, relativeTo: .body))
                        .frame(height: 19,alignment: .bottom)
                }.padding(1)

                
                Text("You've run a total")
                    .font(Font.custom("Gilroy", size: 14, relativeTo: .body))
                    .foregroundColor(Color("CheckGreen"))
                Text("of 29 miles!")
                    .font(Font.custom("Gilroy", size: 14, relativeTo: .body))
                    .foregroundColor(Color("CheckGreen"))
                    .padding(.bottom, 12)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 25)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 6)
                .foregroundColor(Color("ActivityBorderColor"))
            )
            .padding(20)
        }
    }
}

struct Checkmark: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel
    
    var size: CGFloat
    var isOn: Bool
    //var activityId: String
    var activity: Activity
    
    @AppStorage("Jello")
    var a: Data = Data()
    
    var body: some View {
        if isOn {
            Button(action: {
                activityViewModel.activityCheckmarkClicked(id: activity.id, isOn: !isOn)
            }, label: {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 5)
                        .frame(width: size, height: size)
                        .foregroundColor(Color("CheckGreen"))
                    Circle()
                        .frame(width: size, height: size)
                        .foregroundColor(Color("CheckGreen"))
                    CustomSVG(name: "Checkmark", size: 50, tintColor: UIColor.white)
                        .frame(width: size + 20, height: size + 20)
                }
            })
        } else {
            Button(action: {
                activityViewModel.activityCheckmarkClicked(id: activity.id, isOn: !isOn)
            }, label: {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 5)
                        .frame(width: size, height: size)
                        .foregroundColor(Color("CheckGreen"))
                    CustomSVG(name: "Checkmark", size: 50, tintColor: UIColor.white.withAlphaComponent(0))
                        .frame(width: size + 20, height: size + 20)
                }
            })
        }
    }
}

struct CustomSVG: UIViewRepresentable {
    var name: String
    var size: Int
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
        if var image = UIImage(named: name) {
            image = image.withTintColor(tintColor)
            image = image.resized(to: CGSize(width: size, height: size))
            uiView.image = image
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
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
    static let activityViewModel = ActivityViewModel()
    
    static var previews: some View {
        HomePage().preferredColorScheme(.light).environmentObject(activityViewModel)
    }
}
