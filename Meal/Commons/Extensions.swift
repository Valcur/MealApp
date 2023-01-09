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
            .background(color.cornerRadius(cornerRadius).shadow(color: Color("ShadowColor"), radius: shadowRadius, y: shadowRadius / 2).padding(shadowRadius < 5 ? 5 : shadowRadius))
            
    }
    
    func scrollableSheetVStack() -> some View {
        GeometryReader { geo in
            ScrollView(.vertical) {
                self.padding(.horizontal, 20).padding(.top, 20).frame(minHeight: geo.size.height)
            }.frame(width: geo.size.width)
        }
    }
}

extension Text {
    func largeTitle(style: TextStyle = .primary, numberOfLine: Int = 2) -> some View {
        self
            .font(ViewSizes._title())
            .fontWeight(.bold)
            .foregroundColor(style == .primary ? .accentColor: Color("TextColor"))
            .frame(minHeight: CGFloat(30 * numberOfLine))
            .scaledToFit()
            .minimumScaleFactor(0.5)
    }
    
    func title(style: TextStyle = .primary) -> some View {
        self
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(style == .primary ? Color("TextColor") : .accentColor)
    }
    
    func subTitle(style: TextStyle = .primary) -> some View {
        self
            .font(.headline)
            .fontWeight(style == .primary ? .bold : .regular)
            .foregroundColor(style == .primary ? Color("TextColor") : .gray)
    }
    
    func headLine(style: TextStyle = .primary) -> some View {
        self
            .font(.headline)
            .fontWeight(.regular)
            .foregroundColor(style == .primary ? Color("TextColor") : .gray)
            .fixedSize(horizontal: false, vertical: true)
            .padding(0)
    }
    
    enum TextStyle {
        case primary
        case secondary
    }
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
    let title: String
    let isCompact: Bool
    
    init(title: String, isCompact: Bool = false) {
        self.title = title
        self.isCompact = isCompact
    }
    
    var body: some View {
        HStack() {
            if !isCompact {
                Spacer()
            }
            Text(NSLocalizedString(title, comment: title))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(minWidth: 100)
                .roundedCornerRectangle(color: .accentColor)
            if !isCompact {
                Spacer()
            }
        }
    }
}

