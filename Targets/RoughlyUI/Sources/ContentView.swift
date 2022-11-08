import SwiftUI
import RoughlyKit

public struct ContentView: View {
    private var measures: [RoughlyKit.Category]
    
    @State var units: Units
    @State var showModal =  false
    
    public init(inputValue: String, unit: Unit) {
        measures = Category.allCases
        units = Units(
            inputValue: inputValue,
            data: [
                .init(title: "Area", rows: [UnitArea.squareMeters, UnitArea.squareKilometers, UnitArea.squareMiles, UnitArea.squareYards]),
                .init(title: "Weight", rows: [UnitMass.grams, UnitMass.kilograms, UnitMass.pounds, UnitMass.carats, UnitMass.ounces])
            ],
            favorites: ("Favorites", [UnitArea.squareMeters, UnitMass.grams]),
            selected: unit,
            recentSelected: ("Recent", [UnitArea.squareMeters])
        )
    }
    
    enum FocusField: Hashable {
        case field
    }
    
    @FocusState private var focusedField: FocusField?
    
    public var body: some View {
        NavigationStack {
            HStack{
                TextField(text: $units.inputValue, axis: .horizontal) {
                    Text("Enter value")
                }
                .focused($focusedField, equals: .field)
                .task {
                    self.focusedField = .field
                }
                .font(.largeTitle)
                .textFieldStyle(.automatic)
                .keyboardType(.decimalPad)
                Button {
                    showModal.toggle()
                }label: {
                    HStack {
                        Text(units.selected.symbol).font(.title)
                        Image(systemName: "chevron.up")
                    }
                }.buttonStyle(.bordered)
                    .sheet(isPresented: $showModal) {
                        UnitsView(units: $units)
                    }
                
            }.padding()
            Spacer()
            if let val = Double(units.inputValue) {
                let sorted = measures
                    .filter({ category in
                        switch category {
                        case let .weight(weight):
                            guard let selectedUnit = units.selected as? UnitMass else {return false}
                            let measure = Measurement(value: val, unit: selectedUnit)
                            let converted = weight.times(measure).value
                            return converted > 0.9 && converted < 11
                            
                        case let .area(area):
                            guard let selectedUnit = units.selected as? UnitArea else {return false}
                            let measure = Measurement(value: val, unit: selectedUnit)
                            let converted = area.times(measure).value
                            return converted > 0.9 && converted < 11
                        }
                    })
                    .sorted { lhs, rhs in
                        switch (lhs, rhs) {
                        case let (.area(area1), .area(area2)):
                            return area1.measurement < area2.measurement
                            
                        case let (.weight(weight1), .weight(weight2)):
                            return weight1.measurement < weight2.measurement
                            
                        case (.weight, .area), (.area, .weight):
                            return false
                        }
                    }
                
                List(sorted) { category in
                    VStack(alignment: .leading) {
                        UnitRow(
                            measurement: Measurement(value: Double(category.times(unit: units.selected, val: val) ?? 0), unit: category.unit)
                        )
                    }
                }
            }
        }
    }
}

struct Units {
    struct Section: Identifiable, Hashable {
        struct Row: Identifiable, Hashable {
            let title: String
            var id: String {title}
        }
        var id: String {title}
        let title: String
        let rows: [Unit]
    }
    
    var inputValue: String
    let data: [Section]
    var favorites: (String, [Unit])
    var selected: Unit
    var recentSelected: (String, [Unit])
    
    var allSections: [Section] {
        let rows: [Unit] = data.flatMap(\.rows)
        return [
            Section(title: recentSelected.0,
                    rows: recentSelected.1.compactMap { rowID in rows.first { $0 == rowID }} ),
            Section(title: favorites.0,
                    rows: favorites.1.compactMap { rowID in rows.first { $0 == rowID }} ),
        ] + data
    }
}

extension Array<Units.Section>: Identifiable {
    public var id: Int { hashValue }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(inputValue: "5", unit: UnitMass.kilograms)
    }
}

