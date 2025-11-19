//
//  SettingsView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/16/25.
//

import SwiftUI

enum HostOption: Int {
    case localhostDev
    case localhostProd
    case hostname
    case ipAddress
    case url
}

struct SettingsView: View {
    @State var selectedHostOption: HostOption = .localhostDev
    @State var host: String = ""
    
    var reloadDataCompletion: (([Recipe]) -> Void)
    var body: some View {
        NavigationStack {
            List {
                Section("Host") {
                    
                    Picker(selection: $selectedHostOption, label: Text("Host:")) {
                        Text("localhost-dev").tag(HostOption.localhostDev)
                        Text("localhost-prod").tag(HostOption.localhostProd)
                        Text("Hostname").tag(HostOption.hostname)
                        Text("IP Address").tag(HostOption.ipAddress)
                        Text("URL").tag(HostOption.url)
                    }.pickerStyle(MenuPickerStyle())
                    
                    if selectedHostOption != .localhostDev && selectedHostOption != .localhostProd {
                        TextField("", text: $host, axis: .vertical)
                    }
                    
                    Button {
                        UserDefaults.standard.set(selectedHostOption.rawValue, forKey: "hostOption")
                        UserDefaults.standard.set(host, forKey: "hostname")
                        Task {
                            let recipes = await WebService.fetchRecipes()
                            reloadDataCompletion(recipes ?? [])
                        }
                        
                    } label: {
                        Text("Submit")
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .navigationTitle("Settings")
            .onAppear() {
                selectedHostOption = HostOption(rawValue: UserDefaults.standard.integer(forKey: "hostOption")) ?? .localhostDev
                host = UserDefaults.standard.string(forKey: "hostname") ?? ""
            }
        }
    }
}

struct RadioButton: View {
  let label: String
  @Binding var isSelected: Bool

  var body: some View {
      Button(action: {
          self.isSelected.toggle()
      }) {
          HStack {
              Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                  .foregroundColor(isSelected ? .blue : .gray)
              Text(label)
          }
      }
  }
}

struct RadioButtonGroup: View {
  let options: [String]
  @State private var selectedOption: String?

  var body: some View {
      VStack {
          ForEach(options, id: \.self) { option in
              RadioButton(label: option, isSelected: Binding(
                  get: { self.selectedOption == option },
                  set: { newValue in
                      if newValue {
                          self.selectedOption = option
                      }
                  }
              ))
          }
      }
  }
}
