//
//  HomePage.swift
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
    // var viewModel: ActivityViewModel
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
    @AppStorage(UserPrefs.streak.rawValue)
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
        case 6: chars.append(contentsOf: ["F", "F"])
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
        case 6: chars.append(contentsOf: ["F", "F"])
        case 8: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[6...7]), nil, 16)) / 255,
                alpha: .init(strtoul(String(chars[0...1]), nil, 16)) / 255)
    }
}
