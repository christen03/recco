//
//  Supabase.swift
//  Recco
//
//  Created by Christen Xie on 8/12/24.
//

import Supabase
import Foundation

// RLS enabled, so this is fine
let supabase = SupabaseClient(supabaseURL: URL(string: "https://cbbflmkuwumzsyozjkns.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNiYmZsbWt1d3VtenN5b3pqa25zIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MzczMjU5MywiZXhwIjoyMDU5MzA4NTkzfQ.LipVZgfTWzB6Y4nU4AbA_GNdyGPx-caHScMD3G5rZhs")


enum SupabaseFunctions: String {
    case createList = "create_complete_list"
    case updateList = "update_complete_list"
}

