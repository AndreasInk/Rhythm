////
////  DataView.swift
////  DataView
////
////  Created by Andreas on 8/18/21.
////
//
import SwiftUI
import HealthKit
struct DataView: View {
    @State private var date = Date()
    @State private var average = 0.0
    @ObservedObject var health: Health
    @State var data = ChartData(values: [("", 0.0)])
    var body: some View {
        
        VStack {
            HStack {
                Text("Average Heart Rate: " + String(average))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
                DatePicker("", selection: $health.queryDate.anchorDate, displayedComponents: .date)
                    .font(.custom("Poppins", size: 12, relativeTo: .headline))
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
                .onAppear() {
                  //  health.queryDate.anchorDate = date
                    let points = getHeartRateDataAsDoubleArr()
                    average = health.average(numbers: points)
                    data.points = points.map{("", $0)}
                    

                }
            
            }
            HStack {
                TextField("Duration", value: $health.queryDate.duration, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
                    .onChange(of: health.queryDate.duration) { value in
                       
                            let points = getHeartRateDataAsDoubleArr()
                            average = health.average(numbers: points)
                        data.points = points.map{("", $0)}
                    }
                ForEach(DurationType.allCases, id: \.self) { value in
                    Button(action: {
                        withAnimation(.easeInOut) {
                        health.queryDate.durationType = value
                            let points = getHeartRateDataAsDoubleArr()
                            average = health.average(numbers: points)
                        data.points = points.map{("", $0)}
                            print(data.points)
                        }
                    }) {
                        Text(value.rawValue)
                            .font(.custom("Poppins", size: 12, relativeTo: .headline))
                            .foregroundColor(value == health.queryDate.durationType ?  .white : .blue)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(value == health.queryDate.durationType ?  .blue : .white))
                            .scaleEffect(value == health.queryDate.durationType ? 1.1 : 1)
                    }
                }
               
            }
        
                //.opacity(isTutorial ? (tutorialNum == 1 ? 1.0 : 0.1) : 1.0)
            .onChange(of: health.queryDate.anchorDate, perform: { value in
                    
                let points = getHeartRateDataAsDoubleArr()
                average = health.average(numbers: points)
                    data.points = points.map{("", $0)}
                    
                  
                })
            HStack {
                Text("Score")
                    .font(.custom("Poppins-Bold", size: 24, relativeTo: .headline))
                Spacer()
            }  //.opacity(isTutorial ? (tutorialNum == 2 ? 1.0 : 0.1) : 1.0)
            
                
            BarChartView(data: $data, title: "Heart Rate")

           
            Spacer()
        } .padding()
           
        }
    func getHeartRateDataAsDoubleArr() -> [Double] {
        
        return health.healthData.filter{$0.title == HKQuantityTypeIdentifier.heartRate.rawValue && getDateRange(query: health.queryDate, date: $0.date) }.map{$0.data}
    }
                                                                    
    func getDateRange(query: Query, date: Date) -> Bool {
        var isWithinTimePeriod = false
        let scaledDuration = query.durationType == .Week ? query.duration * 86400 * 7 : query.durationType == .Month ? query.duration  * 86400 * 30 : query.durationType == .Year ? query.duration  * 86400 * 365 : 86400 * query.duration
        let range = query.anchorDate.addingTimeInterval(-scaledDuration)...query.anchorDate
        if range.contains(date) {
            isWithinTimePeriod = true
        }
                    return isWithinTimePeriod
                }
    func loadData( completionHandler: @escaping (String) -> Void) {
       
        data = ChartData(values: [("", 0.0)])
        
        
        let filtered = health.codableRisk.filter { data in
            return data.date.get(.weekOfYear) == date.get(.weekOfYear) && date.get(.year) == data.date.get(.year)
        }
        print(filtered)
        let scorePoints = ChartData(values: [("", 0.0)])
        
        for day in 1...7 {
            
       
            let filteredDay = filtered.filter { data in
               
                return data.date.get(.weekday) == day
            }
            
            
            let averageScore =  health.average(numbers: filteredDay.map{$0.risk})
           
            scorePoints.points.append(("\(DayOfWeek(rawValue: day) ?? .Monday)", averageScore))
            
            
           
           
 
            self.data = scorePoints
        
        }
    }
    }

