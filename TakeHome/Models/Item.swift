//
//  Item.swift
//  TakeHome
//
//  Created by Roham Akbari on 2017-09-29.
//  Copyright © 2017 ZipRealty. All rights reserved.
//

import Foundation

enum DTError: LocalizedError {
	case loadError
	case responseError(code: Int)
	case bubbleError(msg: String)
	
	var errorDescription: String? {
		switch self {
		case .loadError:
			return "Error duraing loading"
		case .responseError(let code):
			return "Server responded with error code \(code)"
		case .bubbleError(let msg):
			return msg
		/*default:
			return "Unknown Error"*/
		}
	}
}

class Item: DataTransport {
	
	let strUrl = "http://jsonplaceholder.typicode.com/photos"
	
	/// In the structure we can use optional data types if we
	///	suspect of missing key-values in the returned json dictionary
	struct Schema: Codable {
		let albumId: Int
		let id: Int
		let title: String
		let url: String
		let thumbnailUrl: String
	}
	
	func loadData(compHandler: @escaping (_ ar: [Schema]?, _ error: Error?) -> Void) {
		if let url = URL(string: strUrl) {
			Item.loadRawData(withURL: url, compHandler: { (data, error) in
				
				if let dt = data {
					do {
						let decoded = try JSONDecoder().decode([Schema].self, from: dt)
						compHandler(decoded, nil)
					} catch {
						compHandler(nil, DTError.bubbleError(msg: error.localizedDescription))
					}
				} else {
					compHandler(nil, DTError.loadError)
				}
			})
		} else {
			compHandler(nil, DTError.loadError)
		}
	}
}

class DataTransport {
	
	static func loadRawData(withURL: URL, compHandler: @escaping (_ data: Data?, _ err: Error?) -> Void) {
		
		URLSession.shared.dataTask(with: withURL) { (data: Data?, res: URLResponse?, error: Error?) in
			if let er = error {
				compHandler(nil, er)
			} else if let rs = res as? HTTPURLResponse {
				if rs.statusCode == 200 {
					if let dt = data {
						compHandler(dt, nil)
					} else {
						compHandler(nil, DTError.loadError)
					}
				} else {
					compHandler(nil, DTError.responseError(code: rs.statusCode))
				}
			} else {
				compHandler(nil, DTError.responseError(code: -1))
			}
		}.resume()
	}
}
