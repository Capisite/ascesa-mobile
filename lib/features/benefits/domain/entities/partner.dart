class Partner {
  final String id;
  final String name;
  final String slug;
  final String? portalPartnerUrl;
  final String? logo;
  final String? cover;
  final String? categoryName;
  final String? title;
  final String? about;
  final PartnerOffer? offer;
  final List<PartnerAddress> addressess;
  final String? link;
  final String categoryId;

  Partner({
    required this.id,
    required this.name,
    required this.slug,
    this.portalPartnerUrl,
    this.logo,
    this.cover,
    this.categoryName,
    this.title,
    this.about,
    this.offer,
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
  final String? nameUnit;
  final String? cep;
  final String? neighborhood;
  final String? county;
  final String? street;
  final String? number;
  final String? state;
  final String? complement;
  final String? phone;
  final PartnerLocation? location;

  PartnerAddress({
    this.nameUnit,
    this.cep,
    this.neighborhood,
    this.county,
    this.street,
    this.number,
    this.state,
    this.complement,
    this.phone,
    this.location,
  });
}

class PartnerLocation {
  final String type;
  final List<double> coordinates;

  PartnerLocation({
    required this.type,
    required this.coordinates,
  });
}
