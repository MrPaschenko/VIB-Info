import UIKit

class ArrivalsTableViewController: UITableViewController {
    var arrivalsManager = ArrivalsManager()
    
    var arrivals: [Arrival] = []
    var filteredArrivals: [Arrival] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = String(localized: "arrivals")
        searchBar.placeholder = String(localized: "search")
        
        Task {
            do {
                arrivals = try await arrivalsManager.arrivals
                filteredArrivals = arrivals
                
                tableView.reloadData()
            } catch {
                print("Error getting arrivals: \(error)")
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArrivals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "arrivalIdentifier", for: indexPath)
        
        var configuration = cell.defaultContentConfiguration()
        let arrival = filteredArrivals[indexPath.row]
        
        let lineTrimmed = arrival.line.trimmingCharacters(in: .whitespaces)
        let departureTrimmed = arrival.departure.trimmingCharacters(in: .whitespaces)
        
        var configurationText = "\(lineTrimmed): \(departureTrimmed)"
        
        if departureTrimmed == "" {
            configurationText = lineTrimmed
        }
        
        configuration.text = configurationText
        
        let secondaryText = NSMutableAttributedString()
        
        let greenAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemGreen]
        let yellowAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemYellow]
        
        var timeStatusText = ""
        if arrival.status == "on time" {
            timeStatusText = "\(arrival.time) (\(String(localized: "onTime")))"
        } else {
            timeStatusText = "\(arrival.time) (\(arrival.status)"
        }
        
        let attributedGreenTimeStatus = NSAttributedString(string: timeStatusText, attributes: greenAttributes)
        let attributedYellowTimeStatus = NSAttributedString(string: timeStatusText, attributes: yellowAttributes)
        
        if arrival.status == "on time" {
            secondaryText.append(attributedGreenTimeStatus)
        } else {
            secondaryText.append(attributedYellowTimeStatus)
        }
        
        if arrival.status != "on time" {
            let delayText = " • \(String(localized: "delay")): \(arrival.delay) (\(arrival.delayText))"
            let attributedDelay = NSAttributedString(string: delayText)
            secondaryText.append(attributedDelay)
        }
        
        let gateText = " • \(String(localized: "gate")) \(arrival.gate)"
        let attributedGate = NSAttributedString(string: gateText)
        secondaryText.append(attributedGate)
        
        configuration.secondaryAttributedText = secondaryText
        
        cell.contentConfiguration = configuration
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let arrival = filteredArrivals[indexPath.row]
        
        var detailsMessage = ""
        
        var carrierMessage = "\(String(localized: "carrier")): \(arrival.carrier.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "  ", with: " "))"
        if arrival.lineDescription != arrival.carrier {
            carrierMessage.append(" (\(arrival.lineDescription))")
        }
        detailsMessage.append(carrierMessage)
        
        detailsMessage.append("\n\n\(String(localized: "route")): \(arrival.line)")
        
        detailsMessage.append("\n\n\(String(localized: "departureCity")): \(arrival.departure)")
        
        var timeMessage = "\n\n\(String(localized: "time")): \(arrival.time)"
        if arrival.status == "on time" {
            timeMessage.append(" (\(String(localized: "onTime")))")
        }
        detailsMessage.append(timeMessage)
        
        if arrival.status != "on time" {
            let delayText = "\n\(String(localized: "delay")): \(arrival.delay) (\(arrival.delayText))"
            detailsMessage.append(delayText)
        }
        
        detailsMessage.append("\n\n\(String(localized: "gate")): \(arrival.gate)")
        
        let alertController = UIAlertController(title: String(localized: "arrivalDetails"), message: detailsMessage, preferredStyle: .alert)
        alertController.view.tintColor = .accent
        let okAction = UIAlertAction(title: String(localized: "ok"), style: .cancel)
        let openWebsiteAction = UIAlertAction(title: String(localized: "moreInformation"), style: .default) { _ in
            if let url = URL(string: "https://vib-wien.at/ankuenfte") {
                UIApplication.shared.open(url)
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(openWebsiteAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    @IBAction func refresh(_ sender: UIRefreshControl) {
        Task {
            do {
                arrivals = try await arrivalsManager.arrivals
                filteredArrivals = arrivals
                
                tableView.reloadData()
            } catch {
                print("Error getting arrivals: \(error)")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sender.endRefreshing()
        }
    }
}

//MARK: - Search

extension ArrivalsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredArrivals = searchText == "" ? arrivals : []
        
        for arrival in arrivals {
            if arrival.line.uppercased().contains(searchText.uppercased()) || arrival.departure.uppercased().contains(searchText.uppercased()) {
                filteredArrivals.append(arrival)
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
