//
//  DateOptionsViewController.swift
//  Meltwater Mobile
//
//  Created by Carlos Duarte on 1/18/18.
//  Copyright © 2018 Meltwater. All rights reserved.
//

import Foundation
import UIKit

public protocol DateOptionsSelectionDelegateProtocol: class  {
    func dateRangeOptionSelected(dateOptions: DateRangeOptionsEnumeration, dateRangeSelectorViewController: DateRangeSelectorViewController?)
    func didDismissDateOptionsViewController()
}

public class DateOptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    public var delegate: DateOptionsSelectionDelegateProtocol?
    public var tapRecognizer = UITapGestureRecognizer()
    public var dateRanges = DateRangeOptions()
    var initialTableViewFrame = CGRect.zero
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tapGestureView: UIView!
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(DateOptionsCell.nib, forCellReuseIdentifier:DateOptionsCell.identifier)
        tableView.register(DateOptionsHeaderCell.nib, forCellReuseIdentifier: DateOptionsHeaderCell.identifier)
        tableView.accessibilityIdentifier = "date_options_table"
        tapRecognizer.addTarget(self, action: #selector(dismissVc) )
        tapGestureView.addGestureRecognizer(tapRecognizer)
        view.bringSubviewToFront(tableView)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presentingViewController?.view.alpha = 0.7
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presentingViewController?.view.alpha = 1
    }
    
    // MARK: TableViewDatasource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateRanges.optionsArray.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DateOptionsCell.identifier) as! DateOptionsCell
        let cellData = dateRanges.getRangeDataForUI(atIndex: indexPath.row)
        cell.titleLabel.text = cellData?.title
        if let rangeLabel = dateRanges.getRangeDataForUI(atIndex: indexPath.row) {
            cell.titleLabel.accessibilityIdentifier = rangeLabel.title.lowercased() + "_label"
            cell.daysLabel.accessibilityIdentifier = rangeLabel.title.lowercased() + "_date_label"
            cell.accessibilityIdentifier = rangeLabel.title.lowercased() + "_cell"
        }
        cell.daysLabel.text = cellData?.days
        if cellData?.rangeValue == DateRangeOptionsEnumeration.custom {
            cell.accessoryType = .disclosureIndicator
        }
        cell.separator.isHidden = indexPath.row == dateRanges.optionsArray.count-1 ? true : false
        return cell
        
    }
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(30)
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: DateOptionsHeaderCell.identifier) as! DateOptionsHeaderCell
        header.headerTitleLabel.text = MWKitLocalize.shared.LocalizeWithDefault("DATE_OPTION_HEADER_TITLE", comment: "")
        header.headerTitleLabel.accessibilityIdentifier = "date_options_table_header"
        return header
    }
    
    // MARK: TableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissVc()
        if dateRanges.optionsArray[indexPath.row] == .custom {
            let theDateRange = DateRangeSelectionSessionData.init()
            let customDatePicker = self.createCustomDatePicker(initialDateRange: theDateRange, delegate: self.delegate as? CustomDateRangeSelectionProtocol)
            delegate?.dateRangeOptionSelected(dateOptions: dateRanges.optionsArray[indexPath.row], dateRangeSelectorViewController: customDatePicker)
        } else {
            delegate?.dateRangeOptionSelected(dateOptions: dateRanges.optionsArray[indexPath.row], dateRangeSelectorViewController: nil)
        }
    }

    func createCustomDatePicker(initialDateRange:DateRangeSelectionSessionData, delegate:CustomDateRangeSelectionProtocol?) -> DateRangeSelectorViewController {
        let bundle = MWTools.getBundle()
        let vc = DateRangeSelectorViewController.init(nibName: "DateRangeSelectorView", bundle: bundle)
        vc.setInitialDates(initialDates: initialDateRange)
        vc.delegate = delegate
        return vc
    }
    
    @objc func dismissVc() {
        dismiss(animated: true, completion: nil)
        delegate?.didDismissDateOptionsViewController()
    }
    
}
