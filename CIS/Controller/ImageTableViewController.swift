//
//  ImageTableViewController.swift
//  CIS
//
//  Created by Kevin Pan on 2020-04-30.
//  Copyright © 2020 Kevin Pan. All rights reserved.
//

import UIKit
import CoreData

class ImageTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var fetchResultController: NSFetchedResultsController<ImageMO>!
    var storedOffsets = [Int: CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        loadRecentImages()
        addSideBarMenu(leftMenuButton: menuButton)
    }
    
    @objc func loadRecentImages() {
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<ImageMO> = ImageMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDatetime", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "createdMonthAndYear", cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
            } catch {
                print(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "imageId", for: indexPath)

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        guard let tableViewCell = cell as? ImageTableViewCell else { return }

        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        guard let tableViewCell = cell as? ImageTableViewCell else { return }

        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = fetchResultController.sections?[section].name ?? ""
        return "    " + title
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension ImageTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCollectionId", for: indexPath) as! ImageTableCollectionViewCell
        let imgMO = fetchResultController.sections![collectionView.tag].objects![indexPath.item] as! ImageMO
        cell.imageView.image = UIImage(data: imgMO.imageFile!)
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
}
