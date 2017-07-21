//
//  ProjectOverviewViewController.swift
//  AAShare
//
//  Created by Chen Tom on 06/02/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//

import Foundation
import UIKit

import Realm
import RealmSwift
import RxSwift
import RxCocoa
import Charts

struct ProjectOverviewPerson {
    var name: String = ""
    var inMoney: Float = 0.0
    var outMoney: Float = 0.0
}

class ProjectOverviewViewController: BaseRealmUIViewWithTableController {
    
    @IBOutlet private weak var overviewContainerView: UIView!
    
    private var overviewPieChartView: PieChartView!
    private var overviewPayTypePieChartView: PieChartView!
    private var overviewPayPersonBarChartView: BarChartView!
    
    var projectId: String = "" //活动项目id
    
    
    fileprivate var personOverviews = [ProjectOverviewPerson]()
    
    static func initWithStoryBoard() -> UIViewController {
        return UIStoryboard(name: "Project", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: ProjectOverviewViewController.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initOtherUi()
        
        leftButton?.isHidden = false
        titleLabel?.text = "项目概览"
        
        tableView.register(UINib.init(nibName: String(describing: PersonOverviewListCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: PersonOverviewListCell.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setCharts()
    }
    
    private func initOtherUi() {
        //用来显示饼状图这些
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.clear
        scrollView.isPagingEnabled = true
        overviewContainerView.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(overviewContainerView)
        }
        
        overviewPieChartView = PieChartView()
        overviewPayTypePieChartView = PieChartView()
        overviewPayPersonBarChartView = BarChartView()
        let views = [overviewPieChartView as UIView, overviewPayTypePieChartView as UIView, overviewPayPersonBarChartView as UIView]
        let width = UIScreen.main.bounds.size.width * CGFloat(views.count)
        let subView = UIView()
        subView.addSubViewEqualWidth(subViews: views)
        scrollView.addSubview(subView)
        subView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.height.equalTo(scrollView)
            make.width.equalTo(width)
        }
    }
    
    private func setCharts() {
        setOverviewPieCharts()
        setOverviewPaytypePieCharts()
        setPayPersonBarCharts()
    }
    
    private func setOverviewPieCharts() {
        var predicate = NSPredicate(format: "projectId = %@", projectId)
        let payitems = realm.objects(PayItem.self).filter(predicate)
        
        predicate = NSPredicate(format: "payInOut.name = %@", PayInOut.InComing.rawValue)
        let payins = payitems.filter(predicate)
        
        predicate = NSPredicate(format: "payInOut.name = %@", PayInOut.OutComing.rawValue)
        let payouts = payitems.filter(predicate)
        
        let allinmoney = payins.reduce(0) { $0 + $1.money }
        let alloutmoney = payouts.reduce(0) { $0 + $1.money }
        
        let moneys = [allinmoney, alloutmoney]
        let moneysStr = ["总收款", "总支出"]
        let colorStr = ["0AC775", "fc665e"]
        
        var dataEntries: [ChartDataEntry] = []
        var colors: [UIColor] = []
        for i in 0..<moneys.count {
            let dataEntry = PieChartDataEntry(value: Double(moneys[i]), label: moneysStr[i])
            dataEntries.append(dataEntry)
            
            colors.append(UIColor.tczColorHex(hexString: colorStr[i]))
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartDataSet.entryLabelFont = UIFont.tczMainFontLight(fontSize: 10)
        pieChartData.setValueFont(UIFont.tczMainFontLight(fontSize: 10))
        pieChartDataSet.colors = colors
        overviewPieChartView.data = pieChartData
        overviewPieChartView.chartDescription?.text = "收支总览"
    }
    
    private func setOverviewPaytypePieCharts() {
        var predicate = NSPredicate(format: "projectId = %@", projectId)
        let payitems = realm.objects(PayItem.self).filter(predicate)
        let paytypes = realm.objects(PayType.self)
        
        var dataEntries: [ChartDataEntry] = []
        var colors: [UIColor] = []
        for paytype in paytypes {
            predicate = NSPredicate(format: "payItemType.name = %@", paytype.name)
            let payouts = payitems.filter(predicate)
            let money = payouts.reduce(0){ $0 + $1.money }
            
            if money > 0 {
                let dataEntry = PieChartDataEntry(value: Double(money), label: paytype.name)
                dataEntries.append(dataEntry)
                
                colors.append(UIColor.tczColorRandom())
            }
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartDataSet.entryLabelFont = UIFont.tczMainFontLight(fontSize: 10)
        pieChartData.setValueFont(UIFont.tczMainFontLight(fontSize: 10))
        pieChartDataSet.colors = colors
        overviewPayTypePieChartView.data = pieChartData
        overviewPayTypePieChartView.chartDescription?.text = "支付类别总览"
    }
    
    private func setPayPersonBarCharts() {
        let names = PayPerson.getPayPersonNames(projectId: projectId, inRealm: realm)
        
        let barChartData = BarChartData()
        var colors: [UIColor] = [UIColor]()
        colors.append(UIColor.tczColorHex(hexString: "0AC775"))
        colors.append(UIColor.tczColorHex(hexString: "fc665e"))

        var fromX = 1.0
        for name in names {
            let paypersons = PayPerson.getPayPerson(projectId: projectId, name: name, inRealm: realm)
            var allin: Float = 0.0
            var allout: Float = 0.0
            for p in paypersons {
                if p.payItem.payInOut?.name == PayInOut.OutComing.rawValue {
                    if p.specificMoney {
                        allout = allout + p.payMoney
                    }else {
                        allout = allout + p.payMoney * Float(p.number)
                    }
                    
                }else {
                    if p.specificMoney {
                        allin = allin + p.payMoney
                    }else {
                        allin = allin + p.payMoney * Float(p.number)
                    }
                }
            }
            let indataEntry = BarChartDataEntry(x: Double(fromX), y: Double(allin))
            fromX += 1
            let outdataEntry = BarChartDataEntry(x: Double(fromX), y: Double(allout))
            fromX += 1
            
            let ds = BarChartDataSet(values: [indataEntry, outdataEntry], label: name)
            ds.colors = colors
            barChartData.addDataSet(ds)
            
            var p = ProjectOverviewPerson()
            p.name = name
            p.inMoney = allin
            p.outMoney = allout
            personOverviews.append(p)
        }
        
        overviewPayPersonBarChartView.data = barChartData
        overviewPayPersonBarChartView.chartDescription?.text = "各人支付总览"
    }
    
}

extension ProjectOverviewViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personOverviews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PersonOverviewListCell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonOverviewListCell.self), for: indexPath) as! PersonOverviewListCell
        cell.updateUi(person: personOverviews[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}
