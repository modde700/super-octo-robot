import Foundation

/// A SAME/EAS event code. The attention *sound* is identical for all of them —
/// what changes is the event type and the header/message text.
struct EASEvent: Identifiable, Hashable {
    var id: String { code }
    let code: String        // 3-letter SAME event code
    let name: String        // human-readable name
    let sampleMessage: String

    init(_ code: String, _ name: String, _ sampleMessage: String) {
        self.code = code
        self.name = name
        self.sampleMessage = sampleMessage
    }
}

enum EASCatalog {
    /// A representative slice of the official SAME event-code list.
    /// Full list is public (NWS/FCC). Add/trim freely — these are just labels + text.
    static let all: [EASEvent] = [
        // --- National ---
        EASEvent("EAN", "Emergency Action Notification", "THE FOLLOWING MESSAGE IS TRANSMITTED AT THE REQUEST OF THE NATIONAL AUTHORITIES. (TEST)"),
        EASEvent("NIC", "National Information Center", "National Information Center message. (TEST)"),
        EASEvent("NPT", "National Periodic Test", "This is a National Periodic Test of the alert system. (TEST)"),

        // --- Tests ---
        EASEvent("RWT", "Required Weekly Test", "This is a required weekly test of the emergency alert system. No action is needed. (TEST)"),
        EASEvent("RMT", "Required Monthly Test", "This is a required monthly test of the emergency alert system. No action is needed. (TEST)"),
        EASEvent("DMO", "Practice / Demo Warning", "This is a demonstration message. No action is needed. (TEST)"),

        // --- Warnings ---
        EASEvent("TOR", "Tornado Warning", "A tornado warning is in effect for your area. Take shelter now. (TEST)"),
        EASEvent("SVR", "Severe Thunderstorm Warning", "A severe thunderstorm warning is in effect for your area. (TEST)"),
        EASEvent("FFW", "Flash Flood Warning", "A flash flood warning is in effect. Move to higher ground. (TEST)"),
        EASEvent("FLW", "Flood Warning", "A flood warning is in effect for your area. (TEST)"),
        EASEvent("SVW", "Severe Weather / Special Marine", "Special marine warning in effect. (TEST)"),
        EASEvent("HUW", "Hurricane Warning", "A hurricane warning is in effect for your area. (TEST)"),
        EASEvent("TRW", "Tropical Storm Warning", "A tropical storm warning is in effect for your area. (TEST)"),
        EASEvent("TSW", "Tsunami Warning", "A tsunami warning is in effect. Move to high ground. (TEST)"),
        EASEvent("EWW", "Extreme Wind Warning", "An extreme wind warning is in effect. Take shelter now. (TEST)"),
        EASEvent("BZW", "Blizzard Warning", "A blizzard warning is in effect for your area. (TEST)"),
        EASEvent("WSW", "Winter Storm Warning", "A winter storm warning is in effect for your area. (TEST)"),
        EASEvent("FRW", "Fire Warning", "A fire warning is in effect for your area. (TEST)"),
        EASEvent("EQW", "Earthquake Warning", "An earthquake warning has been issued for your area. (TEST)"),
        EASEvent("CDW", "Civil Danger Warning", "A civil danger warning is in effect. Follow instructions from officials. (TEST)"),
        EASEvent("CEM", "Civil Emergency Message", "A civil emergency message is in effect for your area. (TEST)"),
        EASEvent("LEW", "Law Enforcement Warning", "A law enforcement warning is in effect for your area. (TEST)"),
        EASEvent("HMW", "Hazardous Materials Warning", "A hazardous materials warning is in effect for your area. (TEST)"),
        EASEvent("CAE", "Child Abduction Emergency", "An AMBER Alert has been issued for your area. (TEST)"),
        EASEvent("SPW", "Shelter In Place Warning", "A shelter-in-place warning is in effect. Remain indoors. (TEST)"),

        // --- Watches / Advisories ---
        EASEvent("TOA", "Tornado Watch", "A tornado watch is in effect for your area. (TEST)"),
        EASEvent("SVA", "Severe Thunderstorm Watch", "A severe thunderstorm watch is in effect for your area. (TEST)"),
    ]
}
