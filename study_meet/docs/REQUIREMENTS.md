# R1–R41 талаптар картасы

Бұл кесте кодтың қай жерінен талапты көрсетуге болатынын түсіндіреді. Нақты орындалған тексерулер VERIFICATION.md ішінде бөлек жазылған.

| Талап | Іске асқан орны және түсіндірме |
|---|---|
| R1 | models/meeting.dart және profile.dart: final, const, copyWith. Meeting ашық factory арқылы names тізімін List.unmodifiable етіп, жеке const конструкторға береді. |
| R2 | Category.color: exhaustive switch, тек colorScheme рөлдері. |
| R3 | Meeting.empty(), Profile.empty(). Жаңа форма әдепкі мәндерді модельден алады. |
| R4 | count, free, isFull, isPast — getter; contains(name) — параметр алатын әдіс. |
| R5 | Meeting.places record getter, detail ішінде (:taken, :free) destructuring. |
| R6 | String? description, detail collection if pattern; null assertion жоқ. |
| R7 | where/map/fold/any, collection for/if; sort тек toList көшірмесіне. |
| R8 | utils/format.dart, padLeft, сыртқы форматтау пакеті жоқ. |
| R9 | models/countdown.dart sealed Countdown; format.dart exhaustive switch. |
| R10 | shell.dart: тізім мен профиль Shell State ішінде; tab-тарға параметр және callback. |
| R11 | main.dart: ThemeMode MyApp State ішінде MaterialApp үстінде. |
| R12 | setState ішінде өзгеріс қана; await, showDialog, Navigator сыртта. |
| R13 | detail initState: бір минуттық Timer.periodic; dispose: cancel. |
| R14 | Асинхрондық диалог, picker, route және save нәтижелерінен кейін mounted тексеріледі. |
| R15 | detail _join: showDialog<bool> true болса тіркелу; бос атқа Profile әрекеті бар SnackBar. |
| R16 | Толған кездесуге onPressed: null; тіркелген адам үшін Leave session қолжетімді. |
| R17 | form _save: 1 секунд delay, indicator, батырма disabled, mounted, pop. |
| R18 | MeetingCard: Stack avatar, Expanded мәтін, 2 жол ellipsis, favourite батырмасы. |
| R19 | Avatar Positioned badge: FULL немесе N left, free <= 5 болса ғана. |
| R20 | MeetingsTab LayoutBuilder: 600 px breakpoint, ListView.separated / GridView.builder; ұяшық <= 360 px. |
| R21 | Column ішінде іздеу, clear, көлденең ChoiceChips және FilterChip; тізім Expanded ішінде. |
| R22 | main.dart: ColorScheme.fromSeed, dark Brightness; Profile үш ChoiceChip; literal Color/Colors/fontSize жоқ. |
| R23 | EmptyState үш бос жағдайға ортақ; FAB жаңа форма ашады. |
| R24 | Detail Stack header: assets суреті, icon, category және countdown бұрыштарда. |
| R25 | Routes тұрақтылары, routes home, onGenerateRoute типтелген аргументтер, onUnknownRoute. |
| R26 | DetailArguments ішінде Meeting және callbacks; FormArguments ішінде Meeting?; форма Meeting қайтарады. |
| R27 | Shell _create және Detail _edit: await pushNamed<Meeting>, mounted, null, өзгеріс. |
| R28 | Бір Navigator; pushed экран bar-ды жабады; tab ауысуы shell callback арқылы. |
| R29 | DefaultTabController, TabBar, TabBarView; live Participants count, You белгісі. |
| R30 | PopScope canPop: !_dirty; snapshot салыстыруы, discard диалогы, Save bypass. Android gesture құрылғыда тексерілмеген. |
| R31 | Қолмен BackButton/leading жоқ. AppBar мәзірінде Edit және растауы бар Delete. |
| R32 | Shell Drawer: About AlertDialog, расталатын Reset data; tile Navigator.pop арқылы жабылады. |
| R33 | Form + GlobalKey, барлық мәтін TextFormField; validator; Save бір validate; onUserInteraction. |
| R34 | Title 3–60; орын/онлайн ://; limit 1–500 және count-тен аз емес; санат, күн, уақыт; жаңаға future. |
| R35 | State controller/focus lifecycle; input action/type; onTapOutside. |
| R36 | ReadOnly date/time, picker Cancel ескі мәнді сақтайды; бір DateTime құрылады. |
| R37 | SingleChildScrollView; Spacer жоқ; пернетақта ашылғанда жылжитын форма. |
| R38 | Profile controllers модельден, onSubmitted save, group RegExp, fold арқылы N lists. |
| R39 | Flutter SDK + flutter_lints қана; analyze және format нәтижелері VERIFICATION.md ішінде. |
| R40 | Жобаның жергілікті .git тарихында кемінде 12 мазмұнды коммит. |
| R41 | README: domain, үш нақты веб скриншот және жеті сөйлемдік Decisions. |

GitHub-қа нақты жіберу пайдаланушының репозиторийінде жасалады; жергілікті Git репозиторийі қашықтағы GitHub репозиторийін алмастырмайды.
