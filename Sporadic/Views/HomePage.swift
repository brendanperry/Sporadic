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
        .transition(.scale)
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
    @AppStorage(UserPrefs.Streak.rawValue)
    var streak = 0
    
    var body: some View {
        VStack {
            Text(Localize.getString("CurrentRhythm"))
                .foregroundColor(Color("SubHeadingColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .footnote))
            Text(self.getStreakText())
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Font.custom("Gilroy", size: 38, relativeTo: .largeTitle))
        }
        .padding()
    }
    
    func getStreakText() -> String {
        return streak == 1 ? "1 day" : "\(streak) days"
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
    let dateHelper = DateHelper()
    
    @AppStorage(UserPrefs.DaysPerWeek.rawValue)
    var days = 3
    
    @AppStorage(UserPrefs.DeliveryTime.rawValue)
    var time = Date()
    
    var body: some View {
        VStack {
            Text(Localize.getString("RandomNotificationDelivery"))
                .font(Font.custom("Gilroy-Medium", size: 18, relativeTo: .footnote))
                .foregroundColor(Color("SubHeadingColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(self.getDeliveryText())
                .font(Font.custom("Gilroy", size: 30, relativeTo: .title))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
        }
        .padding()
    }
    
    func getDeliveryText() -> String {
        let time = dateHelper.getTime(date: time)
        
        var text = "\(days)"
        
        if (days == 1) {
            text += " day"
        } else {
            text += " days"
        }
        
        text += " a week,\ndelivered at \(time)"
        
        return text
    }
}

struct ActivityWidget: View {
    var activity: Activity
    
    @EnvironmentObject var activityViewModel: ActivityViewModel
    
    @State var isEditing = false
    
    @State var selection = "1"
    
    @State var minValue = 0.0
    
    @State var maxValue = 0.0

    @State var isEnabled = true
    
    var body: some View {
        let verticalPadding = CGFloat(!isEditing ? 15 : 35)
        let horizontalPadding = CGFloat(!isEditing ? 25 : 50)
        
        let backgroundWidth = CGFloat(!isEditing ? 170 : 195)
        let backgroundHeight = CGFloat(!isEditing ? 210 : 230)
        let backgroundOffsetX = CGFloat(!isEditing ? 15 : 0)
        let backgroundOffsetY = CGFloat(!isEditing ? 15 : 0)
        
        let buttonOffsetX = CGFloat(!isEditing ? 55 : 70)
        let buttonOffsetY = CGFloat(!isEditing ? -65 : -90)
        let buttonImage = !isEditing ? "pencil.circle.fill" : "xmark.circle.fill"
        
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("ActivityBackgroundColor"))
                    .frame(width: backgroundWidth, height: backgroundHeight)
                    .offset(x: backgroundOffsetX, y: backgroundOffsetY)
                    .transition(.scale)
            }
            Button(action: {
                withAnimation {
                    isEditing.toggle()
                }
            }, label: {
                Image(systemName: buttonImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color("ActivityBorderColor"))
            })
            .offset(x: buttonOffsetX, y: buttonOffsetY)
            VStack {
                header
                if isEditing {
                    editableMilesRange
                } else {
                    milesRange
                }
                if isEditing {
                    isEnabledToggle
                } else {
                    totalMiles
                }
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 6)
                .foregroundColor(Color("ActivityBorderColor"))
            )
            .padding(20)
            .transition(.scale)
        }
    }
    
    private var header : some View {
        VStack {
            CustomSVG(name: activity.name, size: 50, tintColor: UIColor(hexaRGB: "#4146E3")!)
                .frame(width: 50, height: 50)
            Text(activity.name)
                .font(Font.custom("Gilroy", size: 30, relativeTo: .title))
                .padding(.top, -1)
        }
    }
    
    private var totalMiles : some View {
        VStack {
            Text("You've run a total")
                .font(Font.custom("Gilroy", size: 14, relativeTo: .body))
                .foregroundColor(Color("CheckGreen"))
            Text("of 29 miles!")
                .font(Font.custom("Gilroy", size: 14, relativeTo: .body))
                .foregroundColor(Color("CheckGreen"))
                .padding(.bottom, 5)
        }
        .transition(.opacity)

    }
    
    private var isEnabledToggle : some View {
        Toggle("", isOn: $isEnabled)
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: Color("CheckGreen")))
            .transition(.opacity)
    }
    
    private var editableMilesRange : some View {
        HStack (spacing: 1) {
            Button("\(activity.minValue)") {
                print("open fullscreen")
            }
            .frame(width: 50, height: 30, alignment: .center)
            .multilineTextAlignment(.center)
            .foregroundColor(Color("FieldTextColor"))
            .font(Font.custom("Gilroy", size: 19, relativeTo: .body))
            .background(Color("FieldBackgroundColor"))
            .cornerRadius(10)
            Text("-")
                .foregroundColor(Color("ActivityRangeColor"))
                .font(Font.custom("Gilroy", size: 19, relativeTo: .body))
            Button("\(activity.maxValue)") {
                print("open fullscreen")
            }
            .frame(width: 50, height: 30, alignment: .center)
            .multilineTextAlignment(.center)
            .foregroundColor(Color("FieldTextColor"))
            .font(Font.custom("Gilroy", size: 19, relativeTo: .body))
            .background(Color("FieldBackgroundColor"))
            .cornerRadius(10)
            Text("mi")
                .foregroundColor(Color("ActivityRangeColor"))
                .font(Font.custom("Gilroy", size: 13, relativeTo: .body))
                .frame(height: 19,alignment: .bottom)
        }
        .frame(maxWidth: .infinity)
        .transition(.opacity)
    }
    
    private var milesRange : some View {
        HStack (spacing: 0) {
            Text("\(activity.minValue, specifier: "%.1f")-\(activity.maxValue, specifier: "%.1f")")
                .foregroundColor(Color("ActivityRangeColor"))
                .font(Font.custom("Gilroy", size: 19, relativeTo: .body))
            Text("mi")
                .foregroundColor(Color("ActivityRangeColor"))
                .font(Font.custom("Gilroy", size: 13, relativeTo: .body))
                .frame(height: 19,alignment: .bottom)
        }
        .padding(1)
        .transition(.opacity)
    }
}

// TODO : REMOVE
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
