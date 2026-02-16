import '../domain/combo.dart';
import '../domain/ingredient.dart';

class ComboRepositoryLocal {
  Future<List<Combo>> load() async {
    return const [
      Combo(
        id: 'combo_001',
        name: '소맥 황금비율',
        base: ComboBase(type: '소주', ratio: '1'),
        mixers: [
          Ingredient(name: '맥주', ratio: '3'),
        ],
        taste: ['청량', '부드러움'],
        alcoholLevel: '중간',
        difficulty: '쉬움',
        popularity: 100,
        keywords: ['소맥', '소주맥주', '황금비율'],
        extraTags: ['국민조합'],
        steps: ['잔에 맥주를 3만큼 따른다', '소주를 1만큼 천천히 붓는다'],
        tools: ['맥주잔'],
        oneLiner: '한국 술자리의 기본값.',
        warning: '과음하기 쉬움.',
      ),
      Combo(
        id: 'combo_002',
        name: '연태 하이볼',
        base: ComboBase(type: '고량주', ratio: '1'),
        mixers: [
          Ingredient(name: '토닉워터', ratio: '3'),
          Ingredient(name: '레몬', ratio: '약간'),
        ],
        taste: ['상큼', '청량'],
        alcoholLevel: '높음',
        difficulty: '쉬움',
        popularity: 95,
        keywords: ['연태', '연태하이볼', '고량주 하이볼'],
        extraTags: ['하이볼', '탄산'],
        steps: ['잔에 얼음을 가득 넣는다', '연태 1 넣고 토닉 3 붓는다', '레몬으로 마무리'],
        tools: ['하이볼 잔', '얼음'],
        oneLiner: '은근히 세다. 방심 금지.',
        warning: '도수가 높아 취기가 빨리 올라올 수 있음.',
      ),
      Combo(
        id: 'combo_003',
        name: '위콜 (위스키 콜라)',
        base: ComboBase(type: '위스키', ratio: '1'),
        mixers: [
          Ingredient(name: '콜라', ratio: '3'),
        ],
        taste: ['달달', '탄산'],
        alcoholLevel: '높음',
        difficulty: '쉬움',
        popularity: 90,
        keywords: ['위콜', '위스키 콜라', 'whisky cola'],
        extraTags: ['하이볼'],
        steps: ['잔에 얼음을 넣는다', '위스키 1, 콜라 3 비율로 붓는다'],
        tools: ['잔', '얼음'],
        oneLiner: '달달하게 시작했다가 훅 간다.',
        warning: '단맛 때문에 과음 주의.',
      ),
    ];
  }
}
