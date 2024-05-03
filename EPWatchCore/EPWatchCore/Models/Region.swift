//
//  Region.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-14.
//

import Foundation

// swiftlint:disable type_body_length file_length
public enum Region: String, Codable, CaseIterable, Identifiable, Equatable {

    case albania        // Albania (AL)
    case austria        // Austria (AT)
    case belgium        // Belgium (BE)
    case bosnia         // Bosnia and Herz. (BA)
    case bulgaria       // Bulgaria (BG)
    case croatia        // Croatia (HR)
    case cyprus         // Cyprus (CY)
    case czech          // Czech Republic (CZ)
    case denmark        // Denmark (DK)
    case estonia        // Estonia (EE)
    case finland        // Finland (FI)
    case france         // France (FR)
    case georgia        // Georgia (GE)
    case germany        // Germany (DE)
    case greece         // Greece (GR)
    case hungary        // Hungary (HU)
    case ireland        // Ireland (IE)
    case italy          // Italy (IT)
    case kosovo         // Kosovo (XK)
    case latvia         // Latvia (LV)
    case lithuania      // Lithuania (LT)
    case luxembourg     // Luxembourg (LU)
    case malta          // Malta (MT)
    case moldova        // Moldova (MD)
    case montenegro     // Montenegro (ME)
    case netherlands    // Netherlands (NL)
    case northMacedonia // North Macedonia (MK)
    case norway         // Norway (NO)
    case poland         // Poland (PL)
    case portugal       // Portugal (PT)
    case romania        // Romania (RO)
    case serbia         // Serbia (RS)
    case slovakia       // Slovakia (SK)
    case slovenia       // Slovenia (SI)
    case spain          // Spain (ES)
    case sweden         // Sweden (SE)
    case switzerland    // Switzerland (CH)
    case turkey         // Turkey (TR)
    case ukraine        // Ukraine (UA)
    case unitedKingdom  // United Kingdom (UK)

    public static var allEnabled: [Region] {
        return Region.allCases.filter({ !$0.disabled })
    }

    /// These regions doesn't (at the time of writing) have any data, will they ever?
    public var disabled: Bool {
        let disabledRegions: [Region] = [
            .albania,
            .bosnia,
            .cyprus,
            .georgia,
            .kosovo,
            .malta,
            .moldova,
            .turkey,
            .unitedKingdom
         ]
        return disabledRegions.contains(self)
    }

    public var name: String {
        func localized(_ key: String.LocalizationValue) -> String {
            String(localized: key, bundle: .module, comment: "Region name")
        }
        switch self {
        case .albania:          return localized("Albania")
        case .austria:          return localized("Austria")
        case .belgium:          return localized("Belgium")
        case .bosnia:           return localized("Bosnia and Herzegovina")
        case .bulgaria:         return localized("Bulgaria")
        case .croatia:          return localized("Croatia")
        case .cyprus:           return localized("Cyprus")
        case .czech:            return localized("Czech Republic")
        case .denmark:          return localized("Denmark")
        case .estonia:          return localized("Estonia")
        case .finland:          return localized("Finland")
        case .france:           return localized("France")
        case .georgia:          return localized("Georgia")
        case .germany:          return localized("Germany")
        case .greece:           return localized("Greece")
        case .hungary:          return localized("Hungary")
        case .ireland:          return localized("Ireland")
        case .italy:            return localized("Italy")
        case .kosovo:           return localized("Kosovo")
        case .latvia:           return localized("Latvia")
        case .lithuania:        return localized("Lithuania")
        case .luxembourg:       return localized("Luxembourg")
        case .malta:            return localized("Malta")
        case .moldova:          return localized("Moldova")
        case .montenegro:       return localized("Montenegro")
        case .netherlands:      return localized("Netherlands")
        case .northMacedonia:   return localized("North Macedonia")
        case .norway:           return localized("Norway")
        case .poland:           return localized("Poland")
        case .portugal:         return localized("Portugal")
        case .romania:          return localized("Romania")
        case .serbia:           return localized("Serbia")
        case .slovakia:         return localized("Slovakia")
        case .slovenia:         return localized("Slovenia")
        case .spain:            return localized("Spain")
        case .sweden:           return localized("Sweden")
        case .switzerland:      return localized("Switzerland")
        case .turkey:           return localized("Turkey")
        case .ukraine:          return localized("Ukraine")
        case .unitedKingdom:    return localized("United Kingdom")
        }
    }

    public var id: String {
        switch self {
        case .albania:          return "AL"
        case .austria:          return "AT"
        case .belgium:          return "BE"
        case .bosnia:           return "BA"
        case .bulgaria:         return "BG"
        case .croatia:          return "HR"
        case .cyprus:           return "CY"
        case .czech:            return "CZ"
        case .denmark:          return "DK"
        case .estonia:          return "EE"
        case .finland:          return "FI"
        case .france:           return "FR"
        case .georgia:          return "GE"
        case .germany:          return "DE"
        case .greece:           return "GR"
        case .hungary:          return "HU"
        case .ireland:          return "IE"
        case .italy:            return "IT"
        case .kosovo:           return "XK"
        case .latvia:           return "LV"
        case .lithuania:        return "LT"
        case .luxembourg:       return "LU"
        case .malta:            return "MT"
        case .moldova:          return "MD"
        case .montenegro:       return "ME"
        case .netherlands:      return "NL"
        case .northMacedonia:   return "MK"
        case .norway:           return "NO"
        case .poland:           return "PL"
        case .portugal:         return "PT"
        case .romania:          return "RO"
        case .serbia:           return "RS"
        case .slovakia:         return "SK"
        case .slovenia:         return "SI"
        case .spain:            return "ES"
        case .sweden:           return "SE"
        case .switzerland:      return "CH"
        case .turkey:           return "TR"
        case .ukraine:          return "UA"
        case .unitedKingdom:    return "UK"
        }
    }

    // Come on, please tell me there's a better way to get this!?
    // This mapping was manually extracted by looking at the bidding zones in:
    // https://transparency.entsoe.eu/transmission-domain/r2/dayAheadPrices/show
    // and finding the corresponding code in:
    // https://transparency.entsoe.eu/content/static_content/Static%20content/web%20api/Guide.html#_areas
    public var priceAreas: [PriceArea] {
        switch self {
        case .albania:
            return [
                PriceArea(title: "AL", id: "BZN|AL", code: "10YAL-KESH-----5")
            ]
        case .austria:
            return [
                PriceArea(title: "AT", id: "BZN|AT", code: "10YAT-APG------L"),
                PriceArea(title: "DE-AT-LU", id: "BZN|DE-AT-LU", code: "10Y1001A1001A63L")
            ]
        case .belgium:
            return [
                PriceArea(title: "BE", id: "BZN|BE", code: "10YBE----------2")
            ]
        case .bosnia:
            return [
                PriceArea(title: "BA", id: "BZN|BA", code: "10YBA-JPCC-----D")
            ]
        case .bulgaria:
            return [
                PriceArea(title: "BG", id: "BZN|BG", code: "10YCA-BULGARIA-R")
            ]
        case .croatia:
            return [
                PriceArea(title: "HR", id: "BZN|HR", code: "10YHR-HEP------M")
            ]
        case .cyprus:
            return [
                PriceArea(title: "CY", id: "BZN|CY", code: "10YCY-1001A0003J")
            ]
        case .czech:
            return [
                PriceArea(title: "CZ", id: "BZN|CZ", code: "10YCZ-CEPS-----N"),
                PriceArea(title: "CZ+DE+SK", id: "BZN|CZ+DE+SK", code: "10YDOM-CZ-DE-SKK")
            ]
        case .denmark:
            return [
                PriceArea(title: "DK1", id: "BZN|DK1", code: "10YDK-1--------W"),
                PriceArea(title: "DK2", id: "BZN|DK2", code: "10YDK-2--------M")
            ]
        case .estonia:
            return [
                PriceArea(title: "EE", id: "BZN|EE", code: "10Y1001A1001A39I")
            ]
        case .finland:
            return [
                PriceArea(title: "FI", id: "BZN|FI", code: "10YFI-1--------U")
            ]
        case .france:
            return [
                PriceArea(title: "FR", id: "BZN|FR", code: "10YFR-RTE------C")
            ]
        case .georgia:
            return [
                PriceArea(title: "GE", id: "BZN|GE", code: "10Y1001A1001B012")
            ]
        case .germany:
            return [
                PriceArea(title: "DE-LU", id: "BZN|DE-LU", code: "10Y1001A1001A82H"),
                PriceArea(title: "DE-AT-LU", id: "BZN|DE-AT-LU", code: "10Y1001A1001A63L"),
                PriceArea(title: "CZ+DE+SK", id: "BZN|CZ+DE+SK", code: "10YDOM-CZ-DE-SKK")
            ]
        case .greece:
            return [
                PriceArea(title: "GR", id: "BZN|GR", code: "10YGR-HTSO-----Y")
            ]
        case .hungary:
            return [
                PriceArea(title: "HU", id: "BZN|HU", code: "10YHU-MAVIR----U")
            ]
        case .ireland:
            return [
                PriceArea(title: "IE(SEM)", id: "BZN|IE(SEM)", code: "10Y1001A1001A59C")
            ]
        case .italy:
            return [
                PriceArea(title: "IT-Calabria", id: "BZN|IT-Calabria", code: "10Y1001C--00096J"),
                PriceArea(title: "IT-Centre-North", id: "BZN|IT-Centre-North", code: "10Y1001A1001A70O"),
                PriceArea(title: "IT-Centre-South", id: "BZN|IT-Centre-South", code: "10Y1001A1001A71M"),
                PriceArea(title: "IT-Foggia", id: "BZN|IT-Foggia", code: "10Y1001A1001A72K"),
                PriceArea(title: "IT-GR", id: "BZN|IT-GR", code: "10Y1001A1001A66F"),
                PriceArea(title: "IT-Malta", id: "BZN|IT-Malta", code: "10Y1001A1001A877"),
                PriceArea(title: "IT-North", id: "BZN|IT-North", code: "10Y1001A1001A73I"),
                PriceArea(title: "IT-North-AT", id: "BZN|IT-North-AT", code: "10Y1001A1001A80L"),
                PriceArea(title: "IT-North-CH", id: "BZN|IT-North-CH", code: "10Y1001A1001A68B"),
                PriceArea(title: "IT-North-FR", id: "BZN|IT-North-FR", code: "10Y1001A1001A81J"),
                PriceArea(title: "IT-North-SI", id: "BZN|IT-North-SI", code: "10Y1001A1001A67D"),
                PriceArea(title: "IT-Priolo", id: "BZN|IT-Priolo", code: "10Y1001A1001A76C"),
                PriceArea(title: "IT-Rossano", id: "BZN|IT-Rossano", code: "10Y1001A1001A77A"),
                PriceArea(title: "IT-SACOAC", id: "BZN|IT-SACOAC", code: "10Y1001A1001A885"),
                PriceArea(title: "IT-SACODC", id: "BZN|IT-SACODC", code: "10Y1001A1001A893"),
                PriceArea(title: "IT-Sardinia", id: "BZN|IT-Sardinia", code: "10Y1001A1001A74G"),
                PriceArea(title: "IT-Sicily", id: "BZN|IT-Sicily", code: "10Y1001A1001A75E"),
                PriceArea(title: "IT-South", id: "BZN|IT-South", code: "10Y1001A1001A788"),
                PriceArea(title: "IT-Brindisi", id: "BZN|IT-Brindisi", code: "10Y1001A1001A699") // Not working?
            ]
        case .kosovo:
            return [
                PriceArea(title: "XK", id: "BZN|XK", code: "10Y1001C--00100H")
            ]
        case .latvia:
            return [
                PriceArea(title: "LV", id: "BZN|LV", code: "10YLV-1001A00074")
            ]
        case .lithuania:
            return [
                PriceArea(title: "LT", id: "BZN|LT", code: "10YLT-1001A0008Q")
            ]
        case .luxembourg:
            return [
                PriceArea(title: "DE-LU", id: "BZN|DE-LU", code: "10Y1001A1001A82H"),
                PriceArea(title: "DE-AT-LU", id: "BZN|DE-AT-LU", code: "10Y1001A1001A63L")
            ]
        case .malta:
            return [
                PriceArea(title: "MT", id: "BZN|MT", code: "10Y1001A1001A93C")
            ]
        case .moldova:
            return [
                PriceArea(title: "MD", id: "BZN|MD", code: "10Y1001A1001A990")
            ]
        case .montenegro:
            return [
                PriceArea(title: "ME", id: "BZN|ME", code: "10YCS-CG-TSO---S")
            ]
        case .netherlands:
            return [
                PriceArea(title: "NL", id: "BZN|NL", code: "10YNL----------L")
            ]
        case .northMacedonia:
            return [
                PriceArea(title: "MK", id: "BZN|MK", code: "10YMK-MEPSO----8")
            ]
        case .norway:
            return [
                PriceArea(title: "NO1", id: "BZN|NO1", code: "10YNO-1--------2"),
                PriceArea(title: "NO2", id: "BZN|NO2", code: "10YNO-2--------T"),
                PriceArea(title: "NO2NSL", id: "BZN|NO2NSL", code: "50Y0JVU59B4JWQCU"),
                PriceArea(title: "NO3", id: "BZN|NO3", code: "10YNO-3--------J"),
                PriceArea(title: "NO4", id: "BZN|NO4", code: "10YNO-4--------9"),
                PriceArea(title: "NO5", id: "BZN|NO5", code: "10Y1001A1001A48H")
            ]
        case .poland:
            return [
                PriceArea(title: "PL", id: "BZN|PL", code: "10YPL-AREA-----S")
            ]
        case .portugal:
            return [
                PriceArea(title: "PT", id: "BZN|PT", code: "10YPT-REN------W")
            ]
        case .romania:
            return [
                PriceArea(title: "RO", id: "BZN|RO", code: "10YRO-TEL------P")
            ]
        case .serbia:
            return [
                PriceArea(title: "RS", id: "BZN|RS", code: "10YCS-SERBIATSOV")
            ]
        case .slovakia:
            return [
                PriceArea(title: "SK", id: "BZN|SK", code: "10YSK-SEPS-----K"),
                PriceArea(title: "CZ+DE+SK", id: "BZN|CZ+DE+SK", code: "10YDOM-CZ-DE-SKK") // Not working?
            ]
        case .slovenia:
            return [
                PriceArea(title: "SI", id: "BZN|SI", code: "10YSI-ELES-----O")
            ]
        case .spain:
            return [
                PriceArea(title: "ES", id: "BZN|ES", code: "10YES-REE------0")
            ]
        case .sweden:
            return [
                PriceArea(title: "SE1", id: "BZN|SE1", code: "10Y1001A1001A44P"),
                PriceArea(title: "SE2", id: "BZN|SE2", code: "10Y1001A1001A45N"),
                PriceArea(title: "SE3", id: "BZN|SE3", code: "10Y1001A1001A46L"),
                PriceArea(title: "SE4", id: "BZN|SE4", code: "10Y1001A1001A47J")
            ]
        case .switzerland:
            return [
                PriceArea(title: "CH", id: "BZN|CH", code: "10YCH-SWISSGRIDZ")
            ]
        case .turkey:
            return [
                PriceArea(title: "TR", id: "BZN|TR", code: "10YTR-TEIAS----W")
            ]
        case .ukraine:
            return [
                PriceArea(title: "UA", id: "BZN|UA", code: "10Y1001C--00003F"),
                PriceArea(title: "UA-BEI", id: "BZN|UA-BEI", code: "10YUA-WEPS-----0"),
                PriceArea(title: "UA-DobTPP", id: "BZN|UA-DobTPP", code: "10Y1001A1001A869"),
                PriceArea(title: "UA-IPS", id: "BZN|UA-IPS", code: "10Y1001C--000182")
            ]
        case .unitedKingdom:
            return [
                PriceArea(title: "GB", id: "BZN|GB", code: "10YGB----------A"),
                PriceArea(title: "GB(ElecLink)", id: "BZN|GB(ElecLink)", code: "11Y0-0000-0265-K"),
                PriceArea(title: "GB(IFA)", id: "BZN|GB(IFA)", code: "10Y1001C--00098F"),
                PriceArea(title: "GB(IFA2)", id: "BZN|GB(IFA2)", code: "17Y0000009369493")
            ]
        }
    }

    public static var current: Region? {
        let currentRegionId = Locale.current.region?.identifier
        return allEnabled.first(where: { $0.id == currentRegionId })
    }

    var suggestedCurrency: Currency {
        switch self {
        case .albania:          return .EUR // .ALL
        case .austria:          return .EUR
        case .belgium:          return .EUR
        case .bosnia:           return .EUR // .BAM
        case .bulgaria:         return .BGN
        case .croatia:          return .EUR // .HRK
        case .cyprus:           return .EUR
        case .czech:            return .CZK
        case .denmark:          return .DKK
        case .estonia:          return .EUR
        case .finland:          return .EUR
        case .france:           return .EUR
        case .georgia:          return .EUR // .GEL
        case .germany:          return .EUR
        case .greece:           return .EUR
        case .hungary:          return .HUF
        case .ireland:          return .EUR
        case .italy:            return .EUR
        case .kosovo:           return .EUR
        case .latvia:           return .EUR
        case .lithuania:        return .EUR
        case .luxembourg:       return .EUR
        case .malta:            return .EUR
        case .moldova:          return .EUR // .MDL
        case .montenegro:       return .EUR
        case .netherlands:      return .EUR
        case .northMacedonia:   return .EUR // .MKD
        case .norway:           return .NOK
        case .poland:           return .PLN
        case .portugal:         return .EUR
        case .romania:          return .RON
        case .serbia:           return .EUR // .RSD
        case .slovakia:         return .EUR
        case .slovenia:         return .EUR
        case .spain:            return .EUR
        case .sweden:           return .SEK
        case .switzerland:      return .CHF
        case .turkey:           return .TRY
        case .ukraine:          return .EUR // .UAH
        case .unitedKingdom:    return .GBP
        }
    }

}

public extension Array where Element == Region {
    func localizedSorted() -> [Region] {
        sorted { a, b in
            return a.name.localizedStandardCompare(b.name) == .orderedAscending
        }
    }
}
