import 'package:prak1/prak1.dart' as prak1;

void main(List<String> arguments) {
  print('Hello world: ${prak1.calculate()}!');
  var name = 'Rijal Dzaki';
  var umur = 21;
  var alamat = 'jl semanggi barat';
  var tinggi = '172';
  var iseng = umur + int.parse(tinggi);
  print('alamat $alamat');
  print('nama $name');
  print('umur $umur');
  print(iseng);
}
