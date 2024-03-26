//
//  Extensions.swift
//  Meal
//
//  Created by Loic D on 07/12/2022.
//

import Foundation
import SwiftUI

extension View {
    func roundedCornerRectangle(padding: CGFloat = 15, cornerRadius: CGFloat = 10, shadowRadius: CGFloat = ViewSizes._5(), margin: CGFloat = 5, color: Color = Color("WhiteBackgroundColor")) -> some View {
        self
            .padding(padding)
            .cornerRadius(cornerRadius)
            .padding(margin)
            .background(color.cornerRadius(cornerRadius).shadowed(shadowRadius: shadowRadius).padding(shadowRadius < 5 ? 5 : shadowRadius))
            
    }
    
    func shadowed(shadowRadius: CGFloat = ViewSizes._5()) -> some View {
        self.shadow(color: Color("ShadowColor"), radius: shadowRadius, y: shadowRadius / 2)
    }
    
    func scrollableSheetVStack() -> some View {
        GeometryReader { geo in
            ScrollView(.vertical) {
                self.padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 20).frame(minHeight: geo.size.height)
            }.frame(width: geo.size.width).onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
    }
    
    func scrollableSheetVStackWithStickyButton(button: AnyView) -> some View {
        ZStack {
            self.padding(.bottom, 50).scrollableSheetVStack().ignoresSafeArea()
            
            StickyBottomButton(button: button).ignoresSafeArea(.keyboard)
        }
    }
    
    func safeAreaScrollableSheetVStackWithStickyButton(button: AnyView) -> some View {
        ZStack {
            self.padding(.bottom, 100).scrollableSheetVStack()
            
            StickyBottomButton(button: button)
        }
    }
    
    func sheetVStackWithStickyButton(button: AnyView) -> some View {
        ZStack {
            self.padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 95).ignoresSafeArea(.container)
            
            StickyBottomButton(button: button)
        }
    }
    
    func textFieldBackground(hPadding: CGFloat = 10, vPadding: CGFloat = 10, style: UIStyle = .primary) -> some View {
        self
            .padding(.horizontal, hPadding).padding(.vertical, vPadding)
            .background(Color(style == .primary ? "BackgroundColor" : "WhiteBackgroundColor").cornerRadius(10))
    }
    
    func tabItemAccentColor(_ accentColor: Color) -> some View {
        if #available(iOS 16, *) {
            return self.tint(accentColor)
        } else {
            return self.accentColor(accentColor)
        }
    }
    
    func blurredBackground() -> some View {
        self
            .background(VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialLight)))
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Text {
    func largeTitle(style: UIStyle = .primary, numberOfLine: Int = 2, accentColor: Color = Color("TextColor")) -> some View {
        self
            .font(ViewSizes._title())
            .fontWeight(.bold)
            .foregroundColor(style == .primary ? accentColor : Color("TextColor"))
            .frame(minHeight: CGFloat(30 * numberOfLine))
            .scaledToFit()
            .minimumScaleFactor(0.4)
    }
    
    func title(style: UIStyle = .primary, accentColor: Color = Color("TextColor")) -> some View {
        self
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(style == .primary ? Color("TextColor") : accentColor)
    }
    
    func subTitle(style: UIStyle = .primary) -> some View {
        self
            .font(.headline)
            .fontWeight(style == .primary ? .bold : .regular)
            .foregroundColor(style == .primary ? Color("TextColor") : .gray)
    }
    
    func headLine(style: UIStyle = .primary) -> some View {
        self
            .font(.headline)
            .fontWeight(.regular)
            .foregroundColor(style == .primary ? Color("TextColor") : .gray)
            .fixedSize(horizontal: false, vertical: true)
            .padding(0)
    }
}

enum UIStyle {
    case primary
    case secondary
}

extension Date {

  static func today() -> Date {
      return Date()
  }

  func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
    return get(.next,
               weekday,
               considerToday: considerToday)
  }

  func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
    return get(.previous,
               weekday,
               considerToday: considerToday)
  }

  func get(_ direction: SearchDirection,
           _ weekDay: Weekday,
           considerToday consider: Bool = false) -> Date {

    let dayName = weekDay.rawValue

    let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }

    assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")

    let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1

    let calendar = Calendar(identifier: .gregorian)

    if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
        return self
    }

    var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
    nextDateComponent.weekday = searchWeekdayIndex

    let date = calendar.nextDate(after: self,
                                 matching: nextDateComponent,
                                 matchingPolicy: .nextTime,
                                 direction: direction.calendarSearchDirection)

        return date!
    }

}

// MARK: Helper methods
extension Date {
  func getWeekDaysInEnglish() -> [String] {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar.weekdaySymbols
  }

  enum Weekday: String {
      case monday, tuesday, wednesday, thursday, friday, saturday, sunday
  }

  enum SearchDirection {
      case next
      case previous

    var calendarSearchDirection: Calendar.SearchDirection {
      switch self {
      case .next:
        return .forward
      case .previous:
        return .backward
      }
    }
  }
}

struct ButtonLabel: View {
    @EnvironmentObject var userPrefs: VisualUserPrefs
    let title: String
    let isCompact: Bool
    let style: UIStyle
    
    init(title: String, isCompact: Bool = false, style: UIStyle = .primary) {
        self.title = title
        self.isCompact = isCompact
        self.style = style
    }
    
    var body: some View {
        HStack() {
            if !isCompact {
                Spacer()
            }
            Text(NSLocalizedString(title, comment: title))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(minWidth: isCompact && UIDevice.current.userInterfaceIdiom == .phone ? 60 : 100)
                .roundedCornerRectangle(color: style == .primary ? userPrefs.accentColor : .black)
            if !isCompact {
                Spacer()
            }
        }
    }
}

struct StickyBottomButton: View {
    let backgroundColor = Color(UIColor.systemBackground)
    let clearColor = Color(UIColor.systemBackground.withAlphaComponent(0))
    let button: AnyView
    
    var body: some View {
        ZStack(alignment: .top){
            button.padding(.top, 30).padding(.bottom, 10).background(
                    VStack(spacing: 0) {
                        LinearGradient(gradient:  Gradient(colors: [clearColor, backgroundColor]), startPoint: .top, endPoint: .bottom)
                            .frame(height: 10)
                        Rectangle()
                            .foregroundColor(backgroundColor)
                            .background(Rectangle()
                                .foregroundColor(backgroundColor).frame(height: 150).offset(y: 100))
                    })
        }.frame(maxHeight: .infinity, alignment: .bottom)
    }
}

extension String {
    func translate() -> String {
        return NSLocalizedString(self, comment: self)
    }
}

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

extension Array {
    mutating func removeRandom() -> Element? {
        if let index = indices.randomElement() {
            return remove(at: index)
        }
        return nil
    }
}


extension View {
    func delaysTouches(for duration: TimeInterval = 0.25, onTap action: @escaping () -> Void = {}) -> some View {
        modifier(DelaysTouches(duration: duration, action: action))
    }
}

fileprivate struct DelaysTouches: ViewModifier {
    @State private var disabled = false
    @State private var touchDownDate: Date? = nil
    
    var duration: TimeInterval
    var action: () -> Void
    
    func body(content: Content) -> some View {
        Button(action: action) {
            content
        }
        .buttonStyle(DelaysTouchesButtonStyle(disabled: $disabled, duration: duration, touchDownDate: $touchDownDate))
        .disabled(disabled)
    }
}

fileprivate struct DelaysTouchesButtonStyle: ButtonStyle {
    @Binding var disabled: Bool
    var duration: TimeInterval
    @Binding var touchDownDate: Date?
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed, perform: handleIsPressed)
    }
    
    private func handleIsPressed(isPressed: Bool) {
        if isPressed {
            let date = Date()
            touchDownDate = date
            
            DispatchQueue.main.asyncAfter(deadline: .now() + max(duration, 0)) {
                if date == touchDownDate {
                    disabled = true
                    
                    DispatchQueue.main.async {
                        disabled = false
                    }
                }
            }
        } else {
            touchDownDate = nil
            disabled = false
        }
    }
}

import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard !results.isEmpty else { return }

            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self, completionHandler: {image, error in
                       DispatchQueue.main.async {
                           guard let image = image as? UIImage else {
                               debugPrint("Error: UIImage is nil")
                               return }
                           self.parent.image = image
                       }
                   })
            } else if provider.hasItemConformingToTypeIdentifier(UTType.webP.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.webP.identifier) {data, err in
                    if let data = data, let img = UIImage.init(data: data) {
                        DispatchQueue.main.async {
                            self.parent.image = img
                        }
                    }
                }
            }
        }
    }
}

extension UIImage {
    private func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func compressImage(height: CGFloat = 30) -> UIImage {
        print(self.size.height)
        if self.size.height <= height * 2 {
            print("Image too small, no compressing")
            return self
        }
        let resizedImage = self.aspectFittedToHeight(height)
        resizedImage.jpegData(compressionQuality: 0.2)
        print("Compressing")
    
        return resizedImage
    }
}

// MARK: - ImageWrapper

public struct ImageWrapper: Codable {

    // Enums

    public enum CodingKeys: String, CodingKey {
        case image
    }

    // Properties

    public let image: UIImage

    // Inits

    public init(image: UIImage) {
        self.image = image
    }

    // Methods

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: CodingKeys.image)
        if let image = UIImage(data: data) {
            self.image = image
        } else {
            // Error Decode
            self.image = UIImage(named: "avocat")!
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let imageData: Data = image.pngData() {
            try container.encode(imageData, forKey: .image)
        } else {
            // Error Encode
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
