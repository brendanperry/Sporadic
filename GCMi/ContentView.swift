//
//  ContentView.swift
//  GCMi
//
//  Created by Brendan Perry on 6/26/21.
//

import SwiftUI

struct ContentView: View {
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
        }
    }
}

struct DeliveryTime: View {
    var body: some View {
        VStack {
            Text("Random Notification Delivery")
                .font(.footnote)
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

struct Activities: View {
    var body: some View {
        VStack {
            Text("Activities")
                .font(.footnote)
                .bold()
                .foregroundColor(Color("SubHeadingColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding(.top)
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack {
                    Activity()
                    Activity()
                    Activity()
                }
            })
        }
    }
}

struct Streak: View {
    var body: some View {
        VStack {
            Text("Current Rhythm")
                .font(.footnote)
                .bold()
                .foregroundColor(Color("SubHeadingColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("16 days!")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title)
        }
        .padding()
    }
}

struct ChallengeButton: View {
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
                        Checkmark(size: 30, isOn: activityCompleted)
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

struct Checkmark: View {
    var size: CGFloat
    var isOn: Bool
    
    var body: some View {
        if isOn {
            Circle()
                .frame(width: size, height: size)
                .foregroundColor(.green)
        } else {
            Circle()
                .stroke(lineWidth: 5)
                .frame(width: size, height: size)
                .foregroundColor(.green)
        }
    }
}

struct Welcome: View {
    var body: some View {
        VStack {
            Text("Welcome back!")
                .font(.footnote)
                .foregroundColor(Color("SubHeadingColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Here's your sporatic goal for today.")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal)
        .padding(.top, 50)
        .padding(.bottom)
    }
}

struct Activity: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color("ActivityBackgroundColor"))
                .frame(width: 120, height: 160)
                .offset(x: 10, y: 7)
            VStack {
                CustomSVG(name: "Biking", tintColor: UIColor(hexaRGB: "#4776EB")!)
                    .frame(width: 50, height: 50)
                Text("Walking")
                    .bold()
                Text("0.5-1mi")
                    .font(.footnote)
                    .bold()
                    .foregroundColor(Color("ActivityRangeColor"))
                Checkmark(size: 25, isOn: true)
            }
            .padding(.vertical)
            .padding(.horizontal, 25)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                .stroke(lineWidth: 3)
                .foregroundColor(Color("ActivityBorderColor"))
            )
            .padding()
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
        ContentView().preferredColorScheme(.dark)
    }
}
