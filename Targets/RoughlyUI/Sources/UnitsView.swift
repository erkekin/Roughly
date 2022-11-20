import Foundation
import SwiftUI
import RoughlyKit

struct UnitRow: View {
    let measure: Measure
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading) {
                    Text("\(measure.roundedIntValue) \(measure.title)")
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
                    if let roundedDoubleValue = measure.roundedDoubleValue {
                        Text("\(roundedDoubleValue) times").font(.body).frame(alignment: .trailing)
                    }
                    if let percentage = measure.percentage {
                        Text("\(percentage) bias").font(.body).frame(alignment: .trailing)
                    }
                }
            }
        }
    }
}

struct UnitsView: View {
    @Binding var units: Units
    @Binding var shown: Bool
    
    public var body: some View {
        NavigationStack {
            List(units.allSections) { section in
                Section(section.title) {
                    ForEach(section.rows, id: \.symbol) { row in
                        Button(action: {
                            units.selected = row
                            shown = false
                        }) {
                            HStack {
                                Text(row.symbol)
                                Spacer()
                                if units.selected == row {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Choose a unit", displayMode: .large)
        }
    }
}
