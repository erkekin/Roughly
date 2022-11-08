import Foundation
import SwiftUI

struct UnitRow: View {
//    let formatter = NumberFormatter()
//    formatter.numberStyle = .decimal
//    formatter.maximumFractionDigits = 2
//
//    let number = NSNumber(value: value)
//    let formattedValue = formatter.string(from: number)!
    let measurement: Measurement<Unit>

    @State var isExpanded: Bool = false
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading) {
                Text("\(Int(round(measurement.value))) \(measurement.unit.symbol)")
                    .font(.title2)
                    .frame(alignment: .leading)
                    .padding()
                
                if isExpanded {
                    HStack {
                        Text("\(measurement.value)").font(.body)
                    }
                }
            }
            Spacer()
            Button {
                isExpanded.toggle()
            } label: {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            }
        }
    }
}

struct UnitsView: View {
    @Binding var units: Units
    
    public var body: some View {
        NavigationStack {
            List(units.allSections) { section in
                Section(section.title) {
                    ForEach(section.rows, id: \.symbol) { row in
                        Button(action: {
                            units.selected = row
                        }) {
                            HStack {
                                Text(row.symbol)
                                Spacer()
                                if units.selected == row {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .foregroundColor(.black)
                    }
                }
            }
            .navigationBarTitle("Choose a unit", displayMode: .large)
        }
    }
}
