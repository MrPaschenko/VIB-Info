import Foundation

struct ArrivalsManager {
    let url = "https://vib-wien.at/fileadmin/apiv4/fetchVIBArrivals.php"
    
    var arrivals: [Arrival] {
        get async throws {
            let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
            return try JSONDecoder().decode(ArrivalsResponseData.self, from: data).result
        }
    }
}
