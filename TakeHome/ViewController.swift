//
//  ViewController.swift
//  TakeHome
//
//  Created by ZapLabs on 3/7/16.
//  Copyright © 2016 ZipRealty. All rights reserved.
//

import UIKit

class CellView: UITableViewCell {
	var indexPath: IndexPath!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		imageView?.image = UIImage(named: "no-image")
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		//fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		imageView?.image = UIImage(named: "no-image")
		textLabel?.text = ""
	}
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Hint: Add a tableView to the main viewController
	private var tableView: UITableView = {
		let tb = UITableView()
		tb.translatesAutoresizingMaskIntoConstraints = false
		return tb
	}()

	private let cellId = "cellId"
	private var arList: [Item.Schema] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.white

        // Hint: Use Auto Layout to tie a UITableView to this viewController
		view.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
		tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		tableView.register(CellView.self, forCellReuseIdentifier: cellId)
		tableView.delegate = self
		tableView.dataSource = self
		
		Item().loadData { [unowned self] (arData, error) in
			
			let alertClosure = { (msg: String) in
				let alert = UIAlertController(title: "Error!", message: msg, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
				// Switch to main thread for UI update
				DispatchQueue.main.async {
					self.present(alert, animated: true, completion: nil)
				}
			}
			
			if let er = error {
				alertClosure(er.localizedDescription)
			} else if let ar = arData {
				self.arList = ar
				// Switch to main thread for UI update
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			} else {
				alertClosure("Data was not retrieved")
			}
		}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // Hint: Add UITableViewDelegate and UITableViewDataSource functions here
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return arList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var cell: CellView
		if let cl = tableView.dequeueReusableCell(withIdentifier: cellId) as? CellView {
			cell = cl
		} else {
			cell = CellView(style: .default, reuseIdentifier: cellId)
		}
		cell.indexPath = indexPath
		
		cell.textLabel?.text = String(format: "%d - %@", indexPath.row, arList[indexPath.row].title)
		if let url = URL(string: arList[indexPath.row].thumbnailUrl) {
			DataTransport.loadRawData(withURL: url, compHandler: { (data, error) in
				if cell.indexPath == indexPath {		//	avoid previously called tasks overwrite correct image
					if let er = error {
						print("\(er.localizedDescription)")
					} else if let dt = data {
						if let img = UIImage(data: dt) {
							DispatchQueue.main.async {
								cell.imageView?.image = img
							}
						}
					} else {
						print("No data for image")
					}
				}
			})
		} else {
			
		}

		return cell
	}
}

