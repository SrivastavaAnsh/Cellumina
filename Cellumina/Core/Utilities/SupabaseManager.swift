import Foundation
import Supabase

/// Configuration for Supabase
/// You need to replace the `apiKey` with your actual Supabase anon key.
/// You can find this in your Supabase Dashboard under Project Settings -> API.
enum SupabaseConfig {
    // Based on the URL in your screenshot, this is your project URL
    static let projectURL = URL(string: "https://feqnazlgcgwhllomtuwe.supabase.co")!
    
    // TODO: Replace with your actual anon key
    static let apiKey = "sb_publishable_lJfgBENTbC-ew8ie70C5OQ_DJVHyqui"
}

/// A singleton manager to handle Supabase database interactions
class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: SupabaseConfig.projectURL,
            supabaseKey: SupabaseConfig.apiKey
        )
    }
}
