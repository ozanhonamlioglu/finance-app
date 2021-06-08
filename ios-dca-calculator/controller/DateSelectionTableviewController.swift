//
//  DateSelectionTableviewController.swift
//  ios-dca-calculator
//
//  Created by ozan honamlioglu on 8.06.2021.
//

import UIKit

class DateSelectionTableViewController: UITableViewController {
    
    var timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjusted?
    var monthInfos: [MonthInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMonthInfos()
    }
    
    private func setupMonthInfos() {
        monthInfos = timeSeriesMonthlyAdjusted?.getMonthInfos() ?? []
    }
    
}

extension DateSelectionTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthInfos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let monthInfo = monthInfos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DateSelectionTableViewCell
        
        cell.configure(with: monthInfo)
        
        return cell
    }
    

}

class DateSelectionTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthsAgoLabel: UILabel!
    
    func configure(with monthInfo: MonthInfo) {
        backgroundColor = .red
    }
    
}
