//
//  ViewController.swift
//  Bree
//
//  Created by Vincent Potrykus on 2022-12-18.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var scheduleButton: UIButton!
    
    @IBOutlet weak var resetButton: UIButton!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedTimeInterval = Double(timePickerData[row]) * 60
        self.labelText.text = String(self.selectedTimeInterval)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(timePickerData[row])
    }

    @IBOutlet weak var labelText: UILabel!
    
    @IBOutlet weak var timePicker: UIPickerView!
    
    
    var timePickerData: [Int] = [Int]()
    
    var timerCounting: Bool = false
    var startTime:Date?
    var stopTime:Date?
    
    let START_TIME_KEY = "startTime"
    let STOP_TIME_KEY = "stopTime"
    let COUNTING_KEY = "countingKey"
    
    var scheduledTimer: Timer!
    
    let userDefaults = UserDefaults.standard
    
    let notificationCenter = UNUserNotificationCenter.current()
    var selectedTimeInterval : Double = 60*60
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBAction func scheduleButton(_ sender: Any) {
        
        if timerCounting {
            setStopTime(date: Date())
            stopTimer()
        } else {
            if let stop = stopTime {
                let restartTime = calcRestartTime(start: startTime!, stop: stop)
                setStopTime(date: nil)
                setStartTime(date: restartTime)
            } else {
                setStartTime(date: Date())
            }
            
   
        }
//        scheduleNotification(localNotification: LocalNotification(identifier: "", title: "Get up!", body: "Time to get up!", timeInverval: self.selectedTimeInterval, repeats: true))
    }
    
    func calcRestartTime(start: Date, stop: Date) -> Date {
        let diff = start.timeIntervalSince(stop)
        return Date().addingTimeInterval(diff)
    }
    

        
    @IBAction func resetButtonAction(_ sender: Any) {
        setStopTime(date: nil)
        setStartTime(date: nil)
        timeLabel.text = makeTimeString(hour: 0, min: 0, sec: 0)
        stopTimer()
    }
    

    
    func setTimeLabel(_ val: Int) {

        let time = secondsToHourMinutesSeconds(val)
        let timeString = makeTimeString(hour: time.0, min: time.1, sec: time.2)
        timeLabel.text = timeString
        print(timeString)
    }
    
    func secondsToHourMinutesSeconds(_ ms: Int) -> (Int, Int, Int)
    {
        let hour = ms / 3600
        let min = (ms % 3600) / 60
        let sec = (ms % 3600) % 60
        return (hour, min, sec)
    }
    
    func makeTimeString(hour: Int, min: Int, sec: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hour)
        timeString += ":"
        timeString += String(format: "%02d", min)
        timeString += ":"
        timeString += String(format: "%02d", sec)
        return timeString
    }
    
    func stopTimer()
        {
            
            if scheduledTimer != nil {
                scheduledTimer.invalidate()
            }
            
            setTimerCounting(false)
            scheduleButton.setTitle("START", for: .normal)
            scheduleButton.setTitleColor(UIColor.systemGreen, for: .normal)
        }
        
    
    func setStartTime(date:Date?) {
         startTime = date
        userDefaults.set(startTime, forKey: START_TIME_KEY )
    }
    
    func setStopTime(date:Date?) {
         stopTime = date
        userDefaults.set(stopTime, forKey: STOP_TIME_KEY )
    }
    
    func setTimerCounting (_ val:Bool) {
         timerCounting = val
        userDefaults.set(timerCounting , forKey: COUNTING_KEY )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
        stopTime = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
        timerCounting = userDefaults.bool(forKey: COUNTING_KEY)
        
        timePickerData = Array(stride(from: 10, through: 50, by: 5))
        self.timePicker.delegate = self
        self.timePicker.dataSource = self
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
        
        }
        
    }
    
    func scheduleNotification(localNotification: LocalNotification) {
        let content = UNMutableNotificationContent()
        content.title = localNotification.title
        content.body = localNotification.body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: localNotification.timeInverval, repeats: localNotification.repeats)
        
        let request = UNNotificationRequest(identifier: localNotification.identifier, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
    
    func sendImmediateNotification(localNotification: LocalNotification) {
            
            let content = UNMutableNotificationContent()
            content.title = localNotification.title
            content.body = localNotification.body
            content.sound = .default

//           let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest(identifier: localNotification.identifier, content: content, trigger: nil)
            print("here")
            notificationCenter.add(request, withCompletionHandler: nil)
            print("notification sent")
    }


}
