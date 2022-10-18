import SwiftUI

public struct ContentView: View {
    @State var inputValue: String = ""
    private var measures: [Category]
    @State var unit: Unit = UnitArea.squareMeters
    
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
                    unit = UnitMass.grams
                } label: {
                    Text(unit.symbol).font(.title2)
                }.buttonStyle(.bordered)

            }.padding()
            Spacer()
            if let val = Double(inputValue) {
                let sorted = measures
                    .filter({ category in
                        switch category {
                        case let .weight(weight):
                            guard unit === UnitMass.grams else {return false}
                            return weight.times(val) > 1 && weight.times(val) < 10
                            
                        case let .area(area):
                            guard unit === UnitArea.squareMeters else {return false}
                            return area.times(val) > 1 && area.times(val) < 10
                        }
                    })
                    .sorted { lhs, rhs in
                        switch (lhs, rhs) {
                        case let (.area(area1), .area(area2)):
                            return area1.times(val) < area2.times(val)
                            
                        case let (.weight(weight1), .weight(weight2)):
                            return weight1.times(val) < weight2.times(val)
                            
                        case (.weight(_), .area(_)), (.area(_), .weight(_)):
                            return false
                        }
                    }
                List(sorted) { category in
                    VStack(alignment: .leading) {
                        Text("\(Int(category.times(val)))").font(.title)
                        Text(category.shortDesc).font(.title2)
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
        case tennisCourt
        case footballArea
        case dinnerPlate
        case iPhoneScreenDisplay
        
        var id: Self { self }
        
        var measurement: Measurement<UnitArea> {
            switch self {
            case .footballArea: return Measurement(value: 5351.215, unit: .squareMeters)
            case .tennisCourt: return Measurement(value: 195.65, unit: .squareMeters)
            case .dinnerPlate: return Measurement(value: 0.0452, unit: .squareMeters)
            case .iPhoneScreenDisplay: return Measurement(value: 0.0083, unit: .squareMeters)
            }
        }
        
        func times(_ inputValue: Double) -> Double {
            inputValue / measurement.value
        }
        
        var string: String {
            switch self {
            case .tennisCourt: return "tennis courts"
            case .footballArea: return "football ground"
            case .dinnerPlate: return "dinner plate"
            case .iPhoneScreenDisplay: return "iPhone screen display"
            }
        }
    }
    
    enum Weight: Hashable, Identifiable, CaseIterable {
        case glassOfWater
        case tablespoon
        
        var id: Self { self }
        
        var measurement: Measurement<UnitMass> {
            switch self {
            case .tablespoon: return Measurement(value: 14.175, unit: .grams)
            case .glassOfWater: return Measurement(value: 250, unit: .grams)
            }
        }
        
        func times(_ inputValue: Double) -> Double {
            inputValue / measurement.value
        }
        
        var string: String {
            switch self {
            case .tablespoon: return "tablespoon"
            case .glassOfWater: return "glass of water"
            }
        }
    }
    
    case area(Area)
    case weight(Weight)
    
    func times(_ inputValue: Double) -> Double {
        switch self {
        case let .area(area): return area.times(inputValue)
        case let .weight(weight): return weight.times(inputValue)
        }
    }
    
    var title: String {
        switch self {
        case .area: return "area"
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(inputValue: "500")
    }
}
