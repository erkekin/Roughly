import SwiftUI
import RoughlyKit

public struct ContentView: View {
    @State var inputValue: String = ""
    private var measures: [RoughlyKit.Category]
    
    @State var units = Units(
        data: [
            .init(title: "Area", rows: [UnitArea.squareMeters, UnitArea.squareKilometers, UnitArea.squareMiles, UnitArea.squareYards]),
            .init(title: "Weight", rows: [UnitMass.grams, UnitMass.kilograms, UnitMass.pounds, UnitMass.carats, UnitMass.ounces])
        ],
        favorites: ("Favorites", [UnitArea.squareMeters, UnitMass.grams]),
        selected: UnitArea.squareMeters,
        recentSelected: ("Recent", [UnitArea.squareMeters])
    )
    @State var showModal =  false
    
    public init(inputValue: String) {
        self.inputValue = inputValue
        measures = Category.allCases
    }
    
    enum FocusField: Hashable {
        case field
    }
    
    @FocusState private var focusedField: FocusField?
    
    public var body: some View {
        NavigationStack {
            HStack{
                TextField(text: $inputValue, axis: .horizontal) {
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
            if let val = Double(inputValue) {
                let sorted = measures
                    .filter({ category in
                        switch category {
                        case let .weight(weight):
                            guard let selectedUnit = units.selected as? UnitMass else {return false}
                            let measure = Measurement(value: val, unit: selectedUnit)
                            let converted = weight.times(measure).value
                            return converted > 1 && converted < 10
                            
                        case let .area(area):
                            guard let selectedUnit = units.selected as? UnitArea else {return false}
                            let measure = Measurement(value: val, unit: selectedUnit)
                            let converted = area.times(measure).value
                            return converted > 1 && converted < 10
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
                        Text("\(category.times(unit: units.selected, val: val)!)").font(.title)
                        Text(category.shortDesc).font(.title)
                    }
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
        ContentView(inputValue: "500")
    }
}

