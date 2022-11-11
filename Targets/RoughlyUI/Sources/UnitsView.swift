import Foundation
import SwiftUI

let formatterDouble: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    return formatter
}()

let formatterInt: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    return formatter
}()

let formatterPercentage: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 3
    return formatter
}()

struct Measure {
    let measurement: Measurement<Unit>
    var roundedIntValue: String {
        formatterInt.string(from: NSNumber(value: measurement.value)) ?? ""
    }
    
    var roundedDoubleValue: String {
        formatterDouble.string(from: NSNumber(value: measurement.value)) ?? ""
    }
    
    var percentage: String? {
        let intDouble = Double(roundedIntValue)
        let doubleDouble = Double(roundedDoubleValue)
        guard let intDouble, let doubleDouble else {return nil}
        let difference = (intDouble - doubleDouble) / 100
        let formatted = formatterPercentage.string(from: NSNumber(value: difference))
        return formatted
    }
}

struct UnitRow: View {
    let measure: Measure
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading) {
                    Text("\(measure.roundedIntValue) \(measure.measurement.unit.symbol)")
                        .font(.title2)
                        .frame(alignment: .leading)
                        .padding(.vertical, 8)
                }
                Spacer()
                Button {
                    isExpanded.toggle()
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            
            if isExpanded {
                VStack(alignment: .trailing) {
                    Text("\(measure.roundedDoubleValue) times").font(.body).frame(alignment: .trailing)
                    Text("\(measure.percentage!) bias").font(.body).frame(alignment: .trailing)
                }
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
