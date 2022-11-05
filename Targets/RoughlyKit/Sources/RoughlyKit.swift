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
        public typealias MyUnit = UnitArea
        
        case trafalgarSquare
        case tennisCourt
        case footballArea
        case basketballCourt
        case kingSizeBed
        case dinnerPlate
        case iPhoneScreenDisplay
        
        public var measurement: Measurement<MyUnit> {
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
        
        public var unit: MyUnit {
            switch self {
            case .trafalgarSquare: return MyUnit(symbol: "trafalgar square", converter: UnitConverterLinear(coefficient: measurement.value))
            case .footballArea: return MyUnit(symbol: "football ground", converter: UnitConverterLinear(coefficient: measurement.value))
            case .basketballCourt: return MyUnit(symbol: "basketball court", converter: UnitConverterLinear(coefficient: measurement.value))
            case .tennisCourt: return MyUnit(symbol: "tennis courts", converter: UnitConverterLinear(coefficient: measurement.value))
            case .kingSizeBed: return MyUnit(symbol: "king size bed", converter: UnitConverterLinear(coefficient: measurement.value))
            case .dinnerPlate: return MyUnit(symbol: "dinner plate", converter: UnitConverterLinear(coefficient: measurement.value))
            case .iPhoneScreenDisplay: return MyUnit(symbol: "iPhone screen display", converter: UnitConverterLinear(coefficient: measurement.value))
            }
        }
    }
    
    public enum Weight: RoughlyUnit {
        public typealias MyUnit = UnitMass
        
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
        
        public var unit: MyUnit {
            switch self {
            case .panda: return MyUnit(symbol: "panda", converter: UnitConverterLinear(coefficient: measurement.value))
            case .cat: return MyUnit(symbol: "cat", converter: UnitConverterLinear(coefficient: measurement.value))
            case .tablespoon: return MyUnit(symbol: "tablespoon", converter: UnitConverterLinear(coefficient: measurement.value))
            case .humanBrain: return MyUnit(symbol: "human brain", converter: UnitConverterLinear(coefficient: measurement.value))
            case .glassOfWater: return MyUnit(symbol: "glass of water", converter: UnitConverterLinear(coefficient: measurement.value))
            case .aaaBattery: return MyUnit(symbol: "battery (AAA)", converter: UnitConverterLinear(coefficient: measurement.value))
            case .paper: return MyUnit(symbol: "Paper", converter: UnitConverterLinear(coefficient: measurement.value))
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
    
    public var shortDesc: String {
        switch self {
        case let .area(area): return area.unit.symbol
        case let .weight(weight): return weight.unit.symbol
        }
    }
    
    public func times(unit: Unit, val: Double) -> Int? {
        switch self {
        case let .weight(weight):
            if let selectedUnit = unit as? UnitMass {
                let measure = Measurement(value: val, unit: selectedUnit)
                return Int(round(weight.times(measure).value))
            }
        case let .area(area):
            if let selectedUnit = unit as? UnitArea {
                let measure = Measurement(value: val, unit: selectedUnit)
               return Int(round(area.times(measure).value))
            }
        }
        return nil
    }
}
