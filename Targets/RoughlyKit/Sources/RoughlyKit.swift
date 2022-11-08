import Foundation

public protocol RoughlyUnit: Hashable, Identifiable, CaseIterable {
    associatedtype MyUnit: Dimension
    var unit: MyUnit {get}
    
    func times(_ measurement: Measurement<MyUnit>) -> Measurement<MyUnit>
}

public extension RoughlyUnit {
    var id: Self { self }
    func times(_ measurement: Measurement<MyUnit>) -> Measurement<MyUnit> {
        measurement.converted(to: unit)
    }
}

public enum Category: Hashable, Identifiable, CaseIterable {
    public static var allCases: [Category] =
    Category.Area.allCases.map(Category.area) + Category.Weight.allCases.map(Category.weight)
    
    public var id: Self { self }
    
    public enum Area: RoughlyUnit {
        case trafalgarSquare
        case tennisCourt
        case footballArea
        case basketballCourt
        case kingSizeBed
        case dinnerPlate
        case iPhoneScreenDisplay
        
        public var measurement: Measurement<UnitArea> {
            switch self {
            case .trafalgarSquare: return Measurement(value: 12000, unit: .baseUnit())
            case .footballArea: return Measurement(value: 5351.215, unit: .baseUnit())
            case .basketballCourt: return Measurement(value: 495.63771840, unit: .baseUnit())
            case .tennisCourt: return Measurement(value: 260.871740, unit: .baseUnit())
            case .kingSizeBed: return Measurement(value: 4.03, unit: .baseUnit())
            case .dinnerPlate: return Measurement(value: 0.0452, unit: .baseUnit())
            case .iPhoneScreenDisplay: return Measurement(value: 0.0083, unit: .baseUnit())
            }
        }
        
        public var unit: UnitArea {
            let converter = UnitConverterLinear(coefficient: measurement.value)
            switch self {
            case .trafalgarSquare: return MyUnit(symbol: "Trafalgar square", converter: converter)
            case .footballArea: return MyUnit(symbol: "football ground", converter: converter)
            case .basketballCourt: return MyUnit(symbol: "basketball court", converter: converter)
            case .tennisCourt: return MyUnit(symbol: "tennis courts", converter: converter)
            case .kingSizeBed: return MyUnit(symbol: "king size bed", converter: converter)
            case .dinnerPlate: return MyUnit(symbol: "dinner plate", converter: converter)
            case .iPhoneScreenDisplay: return MyUnit(symbol: "iPhone screen display", converter: converter)
            }
        }
    }
    
    public enum Weight: RoughlyUnit {
        case cat
        case glassOfWater
        case tablespoon
        case humanBrain
        case aaaBattery
        case paper
        case panda
        
        public var measurement: Measurement<UnitMass> {
            switch self {
            case .panda: return Measurement(value: 150, unit: .baseUnit())
            case .cat: return Measurement(value: 5, unit: .baseUnit())
            case .humanBrain: return Measurement(value: 1.350, unit: .baseUnit())
            case .glassOfWater: return Measurement(value: 0.25, unit: .baseUnit())
            case .aaaBattery: return Measurement(value: 0.024, unit: .baseUnit())
            case .paper: return Measurement(value: 0.005, unit: .baseUnit())
            case .tablespoon: return Measurement(value: 0.014175, unit: .baseUnit())
            }
        }
        
        public var unit: UnitMass {
            let converter = UnitConverterLinear(coefficient: measurement.value)
            switch self {
            case .panda: return MyUnit(symbol: "panda", converter: converter)
            case .cat: return MyUnit(symbol: "cat", converter: converter)
            case .tablespoon: return MyUnit(symbol: "tablespoon", converter: converter)
            case .humanBrain: return MyUnit(symbol: "human brain", converter: converter)
            case .glassOfWater: return MyUnit(symbol: "glass of water", converter: converter)
            case .aaaBattery: return MyUnit(symbol: "battery (AAA)", converter: converter)
            case .paper: return MyUnit(symbol: "paper", converter: converter)
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
    
    public var unit: Unit {
        switch self {
        case let .area(area): return area.unit
        case let .weight(weight): return weight.unit
        }
    }
    
    public func times(unit: Unit, val: Double) -> Double? {
        switch self {
        case let .weight(weight):
            if let selectedUnit = unit as? UnitMass {
                let measure = Measurement(value: val, unit: selectedUnit)
                return weight.times(measure).value
            }
            
        case let .area(area):
            if let selectedUnit = unit as? UnitArea {
                let measure = Measurement(value: val, unit: selectedUnit)
                return area.times(measure).value
            }
        }
        return nil
    }
}
