import 'package:iwealth/models/sector.dart';
import 'package:flutter/material.dart';

class MetadataProvider extends ChangeNotifier {
  List<Metadata> _regions =
      []; // regions districts occupation wards sourceOfIncome
  List<Metadata> _districts = [];
  List<Metadata> _occupations = [];
  List<Metadata> _wards = [];
  List<Metadata> _incomeSource = [];
  List<Metadata> _titles = [];

  List<Metadata> get regions => _regions;
  List<Metadata> get districts => _districts;
  List<Metadata> get occupations => _occupations;
  List<Metadata> get wards => _wards;
  List<Metadata> get incomeSource => _incomeSource;
  List<Metadata> get titles => _titles;
  Metadata? _copOTP;

  set regions(List<Metadata> region) {
    _regions = region;
    notifyListeners();
  }

  set districts(List<Metadata> district) {
    _districts = district;
    notifyListeners();
  }

  set occupations(List<Metadata> occupation) {
    _occupations = occupation;
    notifyListeners();
  }

  set wards(List<Metadata> ward) {
    _wards = ward;
    notifyListeners();
  }

  set incomeSource(List<Metadata> income) {
    _incomeSource = income;
    notifyListeners();
  }

  // set title(List<Metadata> titles) {
  //   _titles = titles;
  //   notifyListeners();
  // }
  set titles(List<Metadata> titlesList) {
    _titles = titlesList;
    notifyListeners();
  }

  List<Metadata> _metadatabank = [];
  List<Metadata> get metadatabank => _metadatabank;

  List<Metadata> _kins = [];
  List<Metadata> get kins => _kins;

  set metadatabank(List<Metadata> metadata) {
    _metadatabank = metadata;
    notifyListeners();
  }

  set kins(List<Metadata> metadata) {
    _kins = metadata;
    notifyListeners();
  }

  Metadata? get copOTP => _copOTP;

  set copOTP(Metadata? metadata) {
    _copOTP = metadata;
    notifyListeners();
  }

// sector
  List<Metadata>? _metadatasector;
  List<Metadata>? get metadatasector => _metadatasector;

  set metadatasector(List<Metadata>? metadata) {
    _metadatasector = metadata;
    notifyListeners();
  }

// source of income
  List<Metadata>? _metadataincome;
  List<Metadata>? get metadataincome => _metadataincome;

  set metadataincome(List<Metadata>? metadata) {
    _metadataincome = metadata;
    notifyListeners();
  }

// Relationship
  List<Metadata>? _metadatarelation;
  List<Metadata>? get metadatarelation => _metadatarelation;

  set metadatarelation(List<Metadata>? metadata) {
    _metadatarelation = metadata;
    notifyListeners();
  }

// Relationship
  List<Metadata>? _metadataincomefreq;
  List<Metadata>? get metadataincomefreq => _metadataincomefreq;

  set metadataincomefreq(List<Metadata>? metadata) {
    _metadataincomefreq = metadata;
    notifyListeners();
  }
}
