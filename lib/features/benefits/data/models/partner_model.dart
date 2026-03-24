import 'package:flutter_project/features/benefits/domain/entities/partner.dart';

class PartnerModel extends Partner {
  PartnerModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.about,
    required super.offer,
    required super.addressess,
    super.link,
    required super.categoryId,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      about: json['about'] ?? '',
      offer: PartnerOfferModel.fromJson(json['offer'] ?? {}),
      addressess: (json['addressess'] as List? ?? [])
          .map((a) => PartnerAddressModel.fromJson(a))
          .toList(),
      link: json['link'],
      categoryId: json['categoryId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'about': about,
      'offer': (offer as PartnerOfferModel).toJson(),
      'addressess': addressess
          .map((a) => (a as PartnerAddressModel).toJson())
          .toList(),
      'link': link,
      'categoryId': categoryId,
    };
  }
}

class PartnerOfferModel extends PartnerOffer {
  PartnerOfferModel({
    required super.title,
    super.term,
    required super.state,
  });

  factory PartnerOfferModel.fromJson(Map<String, dynamic> json) {
    return PartnerOfferModel(
      title: json['title'] ?? '',
      term: json['term'],
      state: json['state'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'term': term,
      'state': state,
    };
  }
}

class PartnerAddressModel extends PartnerAddress {
  PartnerAddressModel({
    super.street,
    super.number,
    super.neighborhood,
    super.city,
    super.state,
  });

  factory PartnerAddressModel.fromJson(Map<String, dynamic> json) {
    return PartnerAddressModel(
      street: json['street'],
      number: json['number'],
      neighborhood: json['neighborhood'],
      city: json['city'] ?? json['county'], // Support both
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
    };
  }
}
