class Rulesmodel {
late String id;
late String rule_name;
late String status_type;
late String min_minutes;
late String max_minutes;
late String penalty_type;
late String penalty_value;
late String penalty_unit;
late String is_active;
late String description;
late String sort_order;


Rulesmodel({
 this.id = '',
 this.rule_name = '',
 this.status_type = '',
 this.min_minutes = '',
 this.max_minutes = '',
 this.penalty_type = '',
 this.penalty_value = '',
 this.penalty_unit = '',
 this.is_active = '',
 this.description = '',
 this.sort_order = '',
});

factory Rulesmodel.fromJson(Map<String,dynamic> json){
return Rulesmodel(
  id: json['id'].toString(),
  rule_name: json['rule_name'].toString(),
  status_type: json['status_type'].toString(),
  min_minutes: json['min_minutes'].toString(),
  max_minutes: json['max_minutes'].toString(),
  penalty_type: json['penalty_type'].toString(),
  penalty_value: json['penalty_value'].toString(),
  penalty_unit: json['penalty_unit'].toString(),
  is_active: json['is_active'].toString(),
  description: json['description'].toString(),
  sort_order: json['sort_order'].toString(),
);
}


}