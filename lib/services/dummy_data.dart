import '../models/user_model.dart';
import '../models/candidate_model.dart';

class DummyData {
  // ============ DATA USER ============
  static final List<UserModel> users = [
    // ✅ ADMIN
    UserModel(
      id: 'admin1',
      nama: 'Administrator',
      nim: '00000000',
      email: 'admin@unpra.ac.id',  // ✅ Email khusus admin
      role: 'admin',
    ),
    // ✅ MAHASISWA (pakai @gmail.com)
    UserModel(
      id: '001',
      nama: 'Zaharani Putri',
      nim: '20242300071',
      email: 'zaharani@gmail.com',  // ✅ Email mahasiswa
    ),
    UserModel(
      id: '002',
      nama: 'Fitriani',
      nim: '2024230010',
      email: 'fitri@gmail.com',
    ),
    UserModel(
      id: '003',
      nama: 'Intan Purnama',
      nim: '2024230012',
      email: 'intan@gmail.com',
    ),
    UserModel(
      id: '004',
      nama: 'Dini Aprilianti',
      nim: '20240014',
      email: 'dini@gmail.com',
    ),
    // Admin data
    UserModel(
      id: 'admin1',
      nama: 'Administrator',
      nim: '-',           // ✅ Admin tidak ada NIM
      email: 'admin@unpra.ac.id',
      role: 'admin',
),
  ];

  // Password
  static final Map<String, String> passwords = {
    'admin@unpra.ac.id': 'admin123',   // ✅ Password admin
    'zaharani@gmail.com': '123456',
    'fitri@gmail.com': '123456',
    'intan@gmail.com': '123456',
    'dini@gmail.com': '123456',
  };

  // ============ DATA KANDIDAT ============
  static final List<CandidateModel> bujangCandidates = [
  CandidateModel(
    id: 'b1', 
    nama: 'Piki Saputra', 
    nomorUrut: 1, 
    visi: 'Membangun kampus unggul, inovatif, dan berdaya saing global', 
    misi: '1. Mengakselerasi prestasi akademik & non-akademik\n2. Menumbuhkan jiwa kepemimpinan dan kewirausahaan\n3. Menjalin kemitraan strategis dengan industri', 
    programKerja: '1. Olimpiade Mahasiswa dan Karya Tulis Ilmiah\n2. Business Plan Competition & Startup Bootcamp\n3. Magang Bersertifikat Bersama Mitra', 
    kategori: 'bujang',
    fotoUrl: 'assets/images/b1.jpg', 
    jumlahSuara: 0
  ),
  CandidateModel(
    id: 'b2', 
    nama: 'Rhado Fahrel Pratama Nasution', 
    nomorUrut: 2, 
    visi: 'Menjadikan kampus sebagai pusat literasi digital dan inovasi teknologi', 
    misi: '1. Meningkatkan literasi teknologi bagi seluruh mahasiswa\n2. Mengembangkan solusi digital untuk masalah kampus\n3. Menciptakan ruang kolaborasi IT dan desain', 
    programKerja: '1. Kelas Coding, UI/UX, dan IoT\n2. Hackathon & Lomba Aplikasi Mobile\n3. Digital Corner: Co-working Space berbasis teknologi', 
    kategori: 'bujang', 
    fotoUrl: 'assets/images/b2.jpg',
    jumlahSuara: 0
  ),
  CandidateModel(
    id: 'b3', 
    nama: 'Dimas Fitrian Saputra', 
    nomorUrut: 3, 
    visi: 'Kampus hijau, sehat, dan berkelanjutan menuju masa depan cerah', 
    misi: '1. Mewujudkan gaya hidup ramah lingkungan\n2. Mengelola energi dan sampah secara mandiri\n3. Membangun taman edukasi hijau', 
    programKerja: '1. Bank Sampah dan Daur Ulang Kreatif\n2. Kampung Vertikal Garden & Hydroponic\n3. Green Youth Forum', 
    kategori: 'bujang', 
    fotoUrl: 'assets/images/b3.jpg',
    jumlahSuara: 0
  ),
  CandidateModel(
    id: 'b4', 
    nama: 'Andea Farhan Pratama', 
    nomorUrut: 4, 
    visi: 'Menginspirasi perubahan, mencetak pemimpin masa depan yang berintegritas', 
    misi: '1. Membangun budaya kritis dan solutif\n2. Mengembangkan soft skills kepemimpinan tingkat lanjut\n3. Menghadirkan program pengabdian masyarakat berdampak', 
    programKerja: '1. Debat Mahasiswa & Diskusi Kebijakan Kampus\n2. Leadership Academy by Mentor Expert\n3. Desa Binaan: Program Mengajar dan Pemberdayaan', 
    kategori: 'bujang', 
    fotoUrl: 'assets/images/b4.jpg',
    jumlahSuara: 0
  ),
];

  static final List<CandidateModel> gadisCandidates = [
  CandidateModel(
    id: 'g1', 
    nama: 'Zaharani Putri', 
    nomorUrut: 1, 
    visi: 'Menciptakan generasi muda yang inovatif, berdaya saing, dan berakhlak mulia', 
    misi: '1. Meningkatkan literasi digital\n2. Mengembangkan soft skills kepemimpinan\n3. Membangun ekosistem belajar yang inklusif', 
    programKerja: '1. Coding for Beginners Workshop\n2. Leadership Camp dan Debat\n3. Program Belajar Bareng Difabel Ramah', 
    kategori: 'gadis', 
    fotoUrl: 'assets/images/g1.jpg',
    jumlahSuara: 0
  ),
  CandidateModel(
    id: 'g2', 
    nama: 'Fitriani', 
    nomorUrut: 2, 
    visi: 'Kampus hijau, sehat, dan berkelanjutan untuk masa depan cerah', 
    misi: '1. Menggerakkan gaya hidup ramah lingkungan\n2. Meningkatkan kesadaran kesehatan mental\n3. Membangun ekonomi kreatif berbasis komunitas', 
    programKerja: '1. Go Green: Bank Sampah dan Vertical Garden\n2. Mental Health First Aid Training\n3. Marketplace Hasil Karya Mahasiswa', 
    kategori: 'gadis', 
    fotoUrl: 'assets/images/g2.jpg',
    jumlahSuara: 0
  ),
  CandidateModel(
    id: 'g3', 
    nama: 'Intan Purnama', 
    nomorUrut: 3, 
    visi: 'Menyala dalam prestasi, bersinar dalam aksi sosial', 
    misi: '1. Mendorong prestasi non-akademik\n2. Memperkuat solidaritas sosial\n3. Mengoptimalkan bakat melalui wadah kreatif', 
    programKerja: '1. Turnamen Olahraga dan Seni Internal\n2. Bakti Sosial ke Panti Asuhan dan Bencana\n3. Talent Showcase Night', 
    kategori: 'gadis', 
    fotoUrl: 'assets/images/g3.jpg',
    jumlahSuara: 0
  ),
  CandidateModel(
    id: 'g4', 
    nama: 'Dini Aprilianti', 
    nomorUrut: 4, 
    visi: 'Menginspirasi perubahan, membangun generasi relevan', 
    misi: '1. Meningkatkan partisipasi mahasiswa dalam aksi sosial\n2. Menghadirkan program pengembangan diri yang aplikatif\n3. Menciptakan budaya kolaborasi antarmahasiswa', 
    programKerja: '1. Gerakan Berbagi: Donasi dan Volunteer\n2. Public Speaking & Personal Branding Bootcamp\n3. Kolaborasi Proyek Lintas Jurusan', 
    kategori: 'gadis', 
    fotoUrl: 'assets/images/g4.jpg',
    jumlahSuara: 0
  ),
];

}