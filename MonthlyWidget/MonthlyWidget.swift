//
//  MonthlyWidget.swift
//  MonthlyWidget
//
//  Created by Carlos Henrique Matos Borges on 10/12/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> ()) {
        let entry = DayEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DayEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DayEntry(date: startDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct DayEntry: TimelineEntry {
    let date: Date
}

struct MonthlyWidgetEntryView : View {
    var entry: DayEntry
    var config: MonthConfig
    
    init(entry: DayEntry) {
        self.entry = entry
        self.config = MonthConfig.determineConfig(from: entry.date)
    }
    
    var body: some View {
        ZStack {
            ContainerRelativeShape().fill(config.backgroundColor.gradient)
            VStack {
                HStack {
                    Text(config.emojiText).font(.title)
                    Text(entry.date.formatted(.dateTime.weekday(.wide))).font(.title3).fontWeight(.bold).minimumScaleFactor(0.6).foregroundColor(.black.opacity(0.6))
                    Spacer()
                }
                Text(entry.date.formatted(.dateTime.day())).font(.system(size: 80, weight: .heavy)).foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
        
    }
}

struct MonthlyWidget: Widget {
    let kind: String = "MonthlyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MonthlyWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MonthlyWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .disableContentMarginsIfNeeded()
    }
}

#Preview(as: .systemSmall) {
    MonthlyWidget()
} timeline: {
    DayEntry(date: .now)
    DayEntry(date: .now)
}

extension WidgetConfiguration {
    func disableContentMarginsIfNeeded() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}
