class Partner {
  final String id;
  final String name;
  final String slug;
  final String about;
  final PartnerOffer offer;
  final List<PartnerAddress> addressess;
  final String? link;
  final String categoryId;

  Partner({
    required this.id,
    required this.name,
    required this.slug,
    required this.about,
    required this.offer,
    required this.addressess,
    this.link,
    required this.categoryId,
  });
}

class PartnerOffer {
  final String title;
  final String? term;
  final String state;

  PartnerOffer({
    required this.title,
    this.term,
    required this.state,
  });
}

class PartnerAddress {
  final String? street;
  final String? number;
  final String? neighborhood;
  final String? city;
  final String? state;

  PartnerAddress({
    this.street,
    this.number,
    this.neighborhood,
    this.city,
    this.state,
  });
}
