String profileRoleLabel(String role) {
  return switch (role) {
    'business' => 'Manufacturer / Business',
    'job_worker' => 'Job Worker / Value Adder',
    'skilled_worker' => 'Skilled Worker / Karigar',
    _ => role,
  };
}

String completionItemLabel(String key) {
  return switch (key) {
    'mobile' => 'Mobile number',
    'owner_name' => 'Owner name',
    'full_address' => 'House, shop or street address',
    'locality' => 'Locality',
    'city' => 'City / district',
    'state' => 'State',
    'pincode' => 'PIN code',
    'location_check' => 'Verify state, city and PIN code',
    'business_name' => 'Business name',
    'business_category' => 'Business category',
    'manufacture_sell_details' => 'Manufacture or sell details',
    'product_type' => 'Product type',
    'shop_photos' => 'Minimum 3 shop photos',
    'workshop_name' => 'Workshop name',
    'workplace_photos' => 'Minimum 3 workplace photos',
    'published_work_card' => 'Add your first work to appear in search',
    'primary_skill' => 'Primary skill',
    'skills' => 'Skills',
    'skill_mastery' => 'Skill details',
    'experience' => 'Experience',
    _ => key.replaceAll('_', ' '),
  };
}

String profileStatusLabel(String status) {
  return switch (status) {
    'pending' => 'Pending review',
    'verified' => 'Verified',
    'changes_requested' => 'Changes requested',
    'rejected' => 'Not approved',
    _ => status,
  };
}
