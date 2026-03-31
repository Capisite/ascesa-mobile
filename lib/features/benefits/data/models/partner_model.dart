import 'package:flutter_project/features/benefits/domain/entities/partner.dart';

class PartnerModel extends Partner {
  PartnerModel({
    required super.id,
    required super.name,
    required super.slug,
    super.portalPartnerUrl,
    super.logo,
    super.cover,
    super.categoryName,
    super.title,
    super.about,
    super.offer,
    required super.addressess,
    super.link,
    required super.categoryId,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      portalPartnerUrl: json['portalPartnerUrl'],
      logo: json['logo'],
      cover: json['cover'],
      categoryName: json['categoryName'],
      title: json['title'],
      about: json['about'],
      offer: json['offer'] != null ? PartnerOfferModel.fromJson(json['offer']) : null,
      addressess: (json['addressess'] as List? ?? [])
          .map((a) => PartnerAddressModel.fromJson(a))
          .toList(),
      link: json['link'],
      categoryId: json['categoryId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'portalPartnerUrl': portalPartnerUrl,
      'logo': logo,
      'cover': cover,
      'categoryName': categoryName,
      'title': title,
      'about': about,
      'offer': offer != null ? (offer as PartnerOfferModel).toJson() : null,
      'addressess': addressess
          .map((a) => (a as PartnerAddressModel).toJson())
          .toList(),
      'link': link,
      'categoryId': categoryId,
    };
  }
}

class PartnerOfferModel extends PartnerOffer {
  PartnerOfferModel({required super.title, super.term, required super.state});

  factory PartnerOfferModel.fromJson(Map<String, dynamic> json) {
    return PartnerOfferModel(
      title: json['title'] ?? '',
      term: json['term'],
      state: json['state'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'term': term, 'state': state};
  }
}

class PartnerAddressModel extends PartnerAddress {
  PartnerAddressModel({
    super.nameUnit,
    super.cep,
    super.neighborhood,
    super.county,
    super.street,
    super.number,
    super.state,
    super.complement,
    super.phone,
    super.location,
  });

  factory PartnerAddressModel.fromJson(Map<String, dynamic> json) {
    return PartnerAddressModel(
      nameUnit: json['nameUnit'],
      cep: json['cep'],
      neighborhood: json['neighborhood'],
      county: json['county'] ?? json['city'],
      street: json['street'],
      number: json['number'],
      state: json['state'],
      complement: json['complement'],
      phone: json['phone'],
      location: json['location'] != null
          ? PartnerLocationModel.fromJson(json['location'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameUnit': nameUnit,
      'cep': cep,
      'neighborhood': neighborhood,
      'county': county,
      'street': street,
      'number': number,
      'state': state,
      'complement': complement,
      'phone': phone,
      'location': location != null
          ? (location as PartnerLocationModel).toJson()
          : null,
    };
  }
}

class PartnerLocationModel extends PartnerLocation {
  PartnerLocationModel({
    required super.type,
    required super.coordinates,
  });

  factory PartnerLocationModel.fromJson(Map<String, dynamic> json) {
    return PartnerLocationModel(
      type: json['type'] ?? 'Point',
      coordinates: (json['coordinates'] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
