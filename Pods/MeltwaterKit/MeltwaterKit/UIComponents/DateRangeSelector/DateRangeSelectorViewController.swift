import UIKit

public protocol CustomDateRangeSelectionProtocol: class  {
    func dateRangeSelected(dateRange:DateRangeSelectionSessionData)
}

public class DateRangeSelectorViewController: UIViewController {
    
    public var theInitialDate:DateRangeSelectionSessionData = DateRangeSelectionSessionData()
    public let dateformatter = DateFormatter()
    public let unitFlags:Set<Calendar.Component> = [ .day, .month, .year, .calendar]
    
    public var theSelectedDate:DateRangeSelectionSessionData?
    public weak var delegate: CustomDateRangeSelectionProtocol?
    @IBOutlet weak var pckStartDate: UIDatePicker!
    @IBOutlet weak var pckEndDate: UIDatePicker!
    @IBOutlet weak var btnSave: UIButton!  // "Save"

    //for setting text
    @IBOutlet weak var lblHeading: UILabel! // "Custom Date Range"
    @IBOutlet weak var btnCancel: UIButton! // "Cancel"
    @IBOutlet weak var lblStart: UILabel! // "Start Date"
    @IBOutlet weak var lblEnd: UILabel! // "End Date"
    @IBOutlet weak var lblTitle: UILabel! // "DATE RANGE"
    
    @IBOutlet weak var btnStartDate: UIView!
    @IBOutlet weak var btnEndDate: UIView!
    @IBOutlet weak var pckEndDateHeight: NSLayoutConstraint!
    @IBOutlet weak var pckStartDateHeight: NSLayoutConstraint!
    let DATE_PICKER_HEIGHT:CGFloat = 215.0
    @IBOutlet weak var lblCurrentStartValue: UILabel!
    @IBOutlet weak var lblCurrentEndValue: UILabel!
    @IBOutlet weak var lblError: UILabel!
    
    @IBOutlet weak var toggleHLine: UIView! // this hline gets hidden when end date is shown so we dont have 2 line border
    
    var errorTooBig:String = MWKitLocalize.shared.LocalizeWithDefault("DATE_RANGE_TOO_BIG", comment: "")
    var errorEndBeforeStart:String = MWKitLocalize.shared.LocalizeWithDefault("DATE_RANGE_END_BEFORE_START", comment: "")
    let SAVE_BLUE:UIColor = MWStyles.MWAqua()
    let SAVE_GRAY:UIColor = MWStyles.MWBorderGray()

    @IBAction func saveRange(_ sender: Any) {
        
        theSelectedDate = DateRangeSelectionSessionData.init(dateRange: .custom)
        theSelectedDate?.customEndDate = pckEndDate.date
        theSelectedDate?.customStartDate = pckStartDate.date
        
        if let date = theSelectedDate {
            delegate?.dateRangeSelected(dateRange: date)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblHeading.text = MWKitLocalize.shared.LocalizeWithDefault("CUSTOM_DATE_RANGE_TITLE", comment: "")
        lblStart.text = MWKitLocalize.shared.LocalizeWithDefault("CUSTOM_LABEL_START_DATE", comment: "")
        lblEnd.text = MWKitLocalize.shared.LocalizeWithDefault("CUSTOM_LABEL_END_DATE", comment: "")
        lblTitle.text = MWKitLocalize.shared.LocalizeWithDefault("DASHBOARDS_ONBOARDING_DATE_POPOVER_TITLE", comment: "").uppercased()

        btnSave.setTitle(MWKitLocalize.shared.LocalizeWithDefault("SAVE_BUTTON", comment: ""), for: .normal)
        btnCancel.setTitle(MWKitLocalize.shared.LocalizeWithDefault("CANCEL_BUTTON", comment: ""), for: .normal)
        btnSave.setTitleColor(SAVE_BLUE, for: .normal)
        btnSave.setTitleColor(SAVE_GRAY, for: .disabled)

        
        lblError.isHidden = true
        dateformatter.dateStyle = DateFormatter.Style.medium
        dateformatter.timeStyle = DateFormatter.Style.none

        
        pckStartDate.isHidden = false
        pckStartDateHeight.constant = DATE_PICKER_HEIGHT
        pckStartDate.accessibilityIdentifier = "start_date_picker"
        pckEndDate.isHidden = true
        pckEndDateHeight.constant = 0.0
        pckEndDate.accessibilityIdentifier = "end_date_picker"
        let tapStart = UITapGestureRecognizer(target: self, action: #selector(DateRangeSelectorViewController.displayStart))
        btnStartDate.isUserInteractionEnabled = true
        btnStartDate.addGestureRecognizer(tapStart)
        
        let tapEnd = UITapGestureRecognizer(target: self, action: #selector(DateRangeSelectorViewController.displayEnd))
        btnEndDate.isUserInteractionEnabled = true
        btnEndDate.addGestureRecognizer(tapEnd)
        
        
        pckStartDate.addTarget(self, action: #selector(self.startDatePickerValueChanged), for: UIControl.Event.valueChanged)
        pckEndDate.addTarget(self, action: #selector(self.endDatePickerValueChanged), for: UIControl.Event.valueChanged)

        initDatePickerValues()

        pckStartDate.accessibilityLabel = "Start Date Picker"
        pckEndDate.accessibilityLabel = "End Date Picker"
}
    
    @objc func displayStart(sender:UITapGestureRecognizer) {
        toggleHLine.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.pckStartDate.isHidden = false
            self.pckEndDateHeight.constant = 0.0
            self.pckEndDate.isHidden = true
            self.pckStartDateHeight.constant = self.DATE_PICKER_HEIGHT
            self.view.layoutIfNeeded() //this line makes the animation magic happen
        })
    }

    @objc func displayEnd(sender:UITapGestureRecognizer) {
        toggleHLine.isHidden = true
        UIView.animate(withDuration: 0.2, animations: {
            self.pckStartDate.isHidden = true
            self.pckStartDateHeight.constant = 0.0
            self.pckEndDate.isHidden = false
            self.pckEndDateHeight.constant = self.DATE_PICKER_HEIGHT
            self.view.layoutIfNeeded() //this line makes the animation magic happen
        })
    }
    
    @objc func startDatePickerValueChanged (datePicker: UIDatePicker) {
        lblCurrentStartValue.text = getDateString(date: datePicker.date)
        validateRange()
    }
    @objc func endDatePickerValueChanged (datePicker: UIDatePicker) {
        lblCurrentEndValue.text = getDateString(date: datePicker.date)
        validateRange()
    }
    
    func validateRange() -> Void {
        if pckStartDate.date > pckEndDate.date {
            //invalid. start after end
            setInvalid(error: self.errorEndBeforeStart)
        }
        else {
            //check for less than 3 months  and a day
            let dateComponents = Calendar.current.dateComponents(self.unitFlags, from: pckStartDate.date, to: pckEndDate.date)
            //if less than 3 months and a day then return true
            if let years = dateComponents.year, let months = dateComponents.month, let days = dateComponents.day {
                if years < 1 {
                    switch months{
                        case 0,1,2:
                            break
                        case 3:
                            if days > 0 {
                                setInvalid(error: self.errorTooBig)
                                return
                            }
                            break
                        default:
                            setInvalid(error: self.errorTooBig)
                            return
                    }
                }
                else{
                    //year too big
                    setInvalid(error: self.errorTooBig)
                    return
                }
            }
            //if any of the conditions drop out we are ok at this point
            setValid()
        }
    }
    
    func setValid() {
        lblError.isHidden = true
        btnSave.isEnabled = true
    }
    
    func setInvalid(error:String) {
        lblError.text = error
        lblError.isHidden = false
        btnSave.isEnabled = false
    }

    func getDateString(date:Date) -> String {
        return dateformatter.string(from: date)
    }

    public func setInitialDates(initialDates:DateRangeSelectionSessionData) ->Void {
        theInitialDate = initialDates
    }
    
    func initDatePickerValues(){
        if theInitialDate.dateRangeType != DateRangeOptionsEnumeration.custom {
            theInitialDate.customEndDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
            theInitialDate.customStartDate = calculateInitStartDateFromEndDate(endDate: theInitialDate.customEndDate!, duration: theInitialDate.dateRangeType)
        }
        else{
            if nil == theInitialDate.customEndDate {
                theInitialDate.customEndDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
            }
            if nil == theInitialDate.customStartDate {
                theInitialDate.customStartDate = calculateInitStartDateFromEndDate(endDate: theInitialDate.customEndDate!, duration: .last7Days)
            }
        }
        //we now have begin and end initial dates
        pckEndDate.date = theInitialDate.customEndDate!
        pckStartDate.date = theInitialDate.customStartDate!

        lblCurrentStartValue.text = getDateString(date: pckStartDate.date)
        lblCurrentEndValue.text = getDateString(date: pckEndDate.date)
    }
    
    func calculateInitStartDateFromEndDate(endDate:Date, duration:DateRangeOptionsEnumeration) -> Date? {
        //if there is a regular type of range passed in we calculate the start date from the end date so that we can init proper
        var dateComponent = DateComponents()
        var startDate:Date? =  Calendar.current.startOfDay(for: endDate) //default to today
        switch duration {
        case .last7Days:
            startDate = Calendar.current.startOfDay(for: endDate)
            dateComponent.day = -6
            startDate = Calendar.current.date(byAdding: dateComponent, to: startDate!)
            break
        case .today:
           //today is the default already set
            break
        case .thisWeek:
            //by default the dateComponents for time will be zero
            startDate = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: endDate))
            break
        case .thisMonth:
            //by default the dateCOmponents for time will be zero
            var component = Calendar.current.dateComponents([.year, .month, .day], from: endDate)
            component.day = 1
            startDate = Calendar.current.date(from: component)
            break
        case .thisQuarter:
            //by default the dateCOmponents for time will be zero
            var component = Calendar.current.dateComponents([.year, .month, .day], from: endDate)
            let curMonth:Int =  component.month ?? 1
            switch curMonth {
            case 1,2,3:
                component.month = 1
            case 4,5,6:
                component.month = 4
            case 7,8,9:
                component.month = 7
            case 10,11,12:
                component.month = 10
            default:
                component.month = 1
                break
            }
            component.day = 1
            startDate = Calendar.current.date(from: component)
            break
        case .last30Days:
            startDate = Calendar.current.startOfDay(for: endDate)
            dateComponent.day = -29
            startDate = Calendar.current.date(byAdding: dateComponent, to: endDate)
            break
            case .custom:
                //do nothing. The label is "Select"
                break
        }
        return startDate
    }
}
