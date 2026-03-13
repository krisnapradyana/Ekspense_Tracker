import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), amount: "Rp 0")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), amount: "Rp 120.000")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.expense_tracker")
        let amount = userDefaults?.string(forKey: "remaining_budget") ?? "Rp 0"
        
        let entry = SimpleEntry(date: Date(), amount: amount)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let amount: String
}

struct ExpenseWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Sisa Budget")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(entry.amount)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            Spacer()
            
            HStack {
                Text("Update: \(entry.date, style: .time)")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color(red: 0.47, green: 0.61, blue: 0.52)) // sagePrimary
        .widgetURL(URL(string: "expensetracker://add"))
    }
}

@main
struct ExpenseWidget: Widget {
    let kind: String = "ExpenseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ExpenseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Expense Tracker")
        .description("Lihat sisa budget dengan cepat.")
        .supportedFamilies([.systemSmall])
    }
}
