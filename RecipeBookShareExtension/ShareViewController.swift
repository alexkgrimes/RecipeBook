//
//  ShareViewController.swift
//  RecipeBookShareExtension
//
//  Created by Alexandra Paras on 11/18/25.
//

import UIKit
import Social
import UniformTypeIdentifiers // Import this for UTType

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        openParentApp()
    }
    
    func openParentApp() {
        Task {
            let recipeURL = await getURL(from: self.extensionContext)
            if let recipeURL, let url = URL(string: "recipebook://parseRecipe?url=\(recipeURL)") {
                print("recipeURL: \(recipeURL)")
                print("url: \(url.absoluteString)")
                var responder: UIResponder? = self
                while responder != nil {
                    if let application = responder as? UIApplication {
                        DispatchQueue.main.async {
                            application.open(url)
                            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                        }
                        
                        break
                    }
                    responder = responder?.next
                }
            }
        }
    }
    
    func getURL(from extensionContext: NSExtensionContext?) async -> String? {
        // 1. Get the first input item and its first attachment
        guard let input = (extensionContext?.inputItems.first as? NSExtensionItem)?.attachments?.first else {
            return nil
        }
        
        // 2. Define the URL data type identifier
        let urlDataType = UTType.url.identifier
        
        // 3. Check if the attachment has an item conforming to the URL type
        guard input.hasItemConformingToTypeIdentifier(urlDataType) else {
            return nil
        }
        
        // 4. Load the item asynchronously
        do {
            let item = try await input.loadItem(forTypeIdentifier: urlDataType)
            let url = item as? URL
            return url?.absoluteString
        } catch {
            print("Error loading URL item: \(error.localizedDescription)")
            return nil
        }
    }
}
