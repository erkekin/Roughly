import SwiftUI

public struct ContentView: View {
    @State var inputValue: String = ""
    private var measures: [Category]
    
    @State var units = Units(
        data: [
            .init(title: "Area", rows: [UnitArea.squareMeters, UnitArea.squareMiles, UnitArea.squareYards]),
            .init(title: "Weight", rows: [UnitMass.grams, UnitMass.pounds, UnitMass.carats, UnitMass.ounces])
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
                        Text(units.selected.symbol)
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
                            guard units.selected is UnitMass else {return false}
                            let converted = weight.times(val)
                            return converted > 1 && converted < 10
                            
                        case let .area(area):
                            guard units.selected is UnitArea else {return false}
                            let converted = area.times(val)
                            return converted > 1 && converted < 10
                        }
                    })
                    .sorted { lhs, rhs in
                        switch (lhs, rhs) {
                        case let (.area(area1), .area(area2)):
                            return area1.measurement.value < area2.measurement.value
                            
                        case let (.weight(weight1), .weight(weight2)):
                            return weight1.measurement.value < weight2.measurement.value
                            
                        case (.weight(_), .area(_)), (.area(_), .weight(_)):
                            return false
                        }
                    }
                
                List(sorted) { category in
                    VStack(alignment: .leading) {
                        switch category {
                        case let .weight(weight):
                            if units.selected is UnitMass {
                                Text("\(weight.times(val))").font(.title)
                            }
                        case let .area(area):
                            if units.selected is UnitArea {
                                Text("\(area.times(val))").font(.title)
                            }
                        }
                        Text(category.shortDesc).font(.title)
                    }
                }
            }
        }
        
    }
}

enum Category: Hashable, Identifiable, CaseIterable {
    static var allCases: [Category] =
    Category.Area.allCases.map(Category.area) + Category.Weight.allCases.map(Category.weight)
    
    var id: Self { self }
    
    enum Area: Hashable, Identifiable, CaseIterable {
        typealias MyUnit = UnitArea
        
        case trafalgarSquare
        case tennisCourt
        case footballArea
        case basketballCourt
        case kingSizeBed
        case dinnerPlate
        case iPhoneScreenDisplay
        
        var id: Self { self }
        
        var measurement: Measurement<UnitArea> {
            switch self {
            case .trafalgarSquare: return Measurement(value: 12000, unit: .squareMeters)
            case .footballArea: return Measurement(value: 5351.215, unit: .squareMeters)
            case .basketballCourt: return Measurement(value: 495.63771840, unit: .squareMeters)
            case .tennisCourt: return Measurement(value: 260.871740, unit: .squareMeters)
            case .kingSizeBed: return Measurement(value: 4.03, unit: .squareMeters)
            case .dinnerPlate: return Measurement(value: 0.0452, unit: .squareMeters)
            case .iPhoneScreenDisplay: return Measurement(value: 0.0083, unit: .squareMeters)
            }
        }
        
        //        var unit: MyUnit {
        //            switch self {
        //            case .trafalgarSquare: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 12000))
        //            case .footballArea: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 5351.215))
        //            case .basketballCourt: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 495.63771840))
        //            case .tennisCourt: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 260.871740))
        //            case .kingSizeBed: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 4.03))
        //            case .dinnerPlate: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 0.0452))
        //            case .iPhoneScreenDisplay: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 0.0083))
        //            }
        //        }
        
        func times(_ measurement: Double) -> Double {
            measurement / self.measurement.value
        }
        
        var string: String {
            switch self {
            case .tennisCourt: return "tennis courts"
            case .footballArea: return "football ground"
            case .basketballCourt: return "basketball court"
            case .dinnerPlate: return "dinner plate"
            case .iPhoneScreenDisplay: return "iPhone screen display"
            case .trafalgarSquare: return "trafalgar square"
            case .kingSizeBed: return "king size bed"
            }
        }
    }
    
    enum Weight: Hashable, Identifiable, CaseIterable {
        typealias MyUnit = UnitMass
        
        case cat
        case glassOfWater
        case tablespoon
        case humanBrain
        case aaaBattery
        case paper
        case panda
        
        var id: Self { self }
        
        var measurement: Measurement<UnitMass> {
            switch self {
            case .panda: return Measurement(value: 150, unit: .kilograms)
            case .cat: return Measurement(value: 5, unit: .kilograms)
            case .tablespoon: return Measurement(value: 14.175, unit: .grams)
            case .humanBrain: return Measurement(value: 1350, unit: .grams)
            case .glassOfWater: return Measurement(value: 250, unit: .grams)
            case .aaaBattery: return Measurement(value: 24, unit: .grams)
            case .paper: return Measurement(value: 5, unit: .grams)
            }
        }
        //
        //        var unit: MyUnit {
        //            switch self {
        //            case .panda: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 150000))
        //            case .cat: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 5000))
        //            case .tablespoon: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 14.175))
        //            case .humanBrain: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 1350))
        //            case .glassOfWater: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 250))
        //            case .aaaBattery: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 24))
        //            case .paper: return MyUnit(symbol: string, converter: UnitConverterLinear(coefficient: 5))
        //            }
        //        }
        //
        
        func times(_ measurement: Double) -> Double {
            measurement / self.measurement.value
        }
        
        var string: String {
            switch self {
            case .panda: return "panda"
            case .cat: return "cat"
            case .tablespoon: return "tablespoon"
            case .humanBrain: return "human brain"
            case .glassOfWater: return "glass of water"
            case .aaaBattery: return "battery (AAA)"
            case .paper: return "Paper"
            }
        }
    }
    
    case area(Area)
    case weight(Weight)
    
    var title: String {
        switch self {
        case .area: return "Area"
        case .weight: return "Weight"
        }
    }
    
    var shortDesc: String {
        switch self {
        case let .area(area): return area.string
        case let .weight(weight): return weight.string
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
    public var id: Int {
        hashValue
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(inputValue: "500")
    }
}

