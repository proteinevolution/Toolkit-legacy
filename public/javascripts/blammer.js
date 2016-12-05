function deselect()
{
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10);
  for(i = 0; i < (blocks*number); i++) {
    $(blammer_form).elements["hits[]"][i].checked = false;
  }
  calculate_forwarding();
}
function select()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10);
  for(i = 0; i < (blocks*number); i++) {
    $(blammer_form).elements["hits[]"][i].checked = true;
  }
  calculate_forwarding();
}
function select_first()
{ 
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10);
  var first = 10;
  for(b = 0; b < blocks; b++) {
    for (i = 0; i < number; i++) {
      if (i < first) {
        $(blammer_form).elements["hits[]"][(b*number+i)].checked = true;
      } else {
        $(blammer_form).elements["hits[]"][(b*number+i)].checked = false;      
      }
    }  
  }
  calculate_forwarding();
}

function change(num, block)
{
  var number = parseInt($('CHECKBOXES').value, 10);
  var blocks = parseInt($('BLOCKS').value, 10);
  var mode = $(blammer_form).elements["hits[]"][(block * number)+num].checked;
  for (b = 0; b < (blocks); b++) {
    $(blammer_form).elements["hits[]"][(b * number)+num].checked = mode;
  }
}

function pasteExample() {

    document.getElementById("sequence_input").value = "<PRE>\n"+
"\n"+
"<b>PSIBLAST 2.5.0+</b>\n"+
"\n"+
"\n"+
"<b><a\n"+
"href=\"https://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=PubMed&cmd=R\n"+
"etrieve&list_uids=9254694&dopt=Citation\">Reference</a>:</b>\n"+
"Stephen F. Altschul, Thomas L. Madden, Alejandro A. Schäffer,\n"+
"Jinghui Zhang, Zheng Hang, Webb Miller, and David J. Lipman (1997),\n"+
"\"Gapped BLAST and PSI-BLAST: a new generation of protein database\n"+
"search programs\", Nucleic Acids Res. 25:3389-3402.\n"+
"\n"+
"\n"+
"<b><a\n"+
"href=\"https://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=PubMed&cmd=R\n"+
"etrieve&list_uids=16218944&dopt=Citation\">Reference for\n"+
"compositional score matrix adjustment</a>:</b>\n"+
"Stephen F. Altschul, John C. Wootton, E. Michael Gertz, Richa\n"+
"Agarwala, Aleksandr Morgulis, Alejandro A. Schäffer, and Yi-Kuo\n"+
"Yu (2005) \"Protein database searches using compositionally adjusted\n"+
"substitution matrices\", FEBS J. 272:5101-5109.\n"+
"\n"+
"\n"+
"<b><a\n"+
"href=\"https://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=PubMed&cmd=R\n"+
"etrieve&list_uids=11452024&dopt=Citation\">Reference for\n"+
"composition-based statistics starting in round 2</a>:</b>\n"+
"Alejandro A. Schäffer, L. Aravind, Thomas L. Madden, Sergei\n"+
"Shavirin, John L. Spouge, Yuri I. Wolf, Eugene V. Koonin, and\n"+
"Stephen F. Altschul (2001), \"Improving the accuracy of PSI-BLAST\n"+
"protein database searches with composition-based statistics and\n"+
"other refinements\", Nucleic Acids Res. 29:2994-3005.\n"+
"\n"+
"\n"+
"\n"+
"<b>Database:</b>\n"+
"   nr70\n"+
"           27,180,568 sequences; 8,746,506,771 total letters\n"+
"\n"+
"Results from round 1\n"+
"\n"+
"\n"+
"<b>Query=</b> <a href=\"https://www.ncbi.nlm.nih.gov/protein/4557853\">gi|4557853|</a><a href=\"https://www.ncbi.nlm.nih.gov/protein/NP_000337.1\">ref|NP_000337.1|</a> transcription factor SOX-9 [Homo\n"+
"sapiens]\n"+
"\n"+
"Length=509\n"+
"                                                                      Score     E\n"+
"Sequences producing significant alignments:                          (Bits)  Value\n"+
"\n"+
"\n"+
"\n"+
"BAD90382.1  mKIAA4243 protein, partial [Mus musculus]                 <a href=#BAD90382.1>998</a>     0.0   \n"+
"XP_017519930.1  PREDICTED: transcription factor SOX-9, partial [M...  <a href=#XP_017519930.1>713</a>     0.0   \n"+
"XP_014902658.1  PREDICTED: transcription factor SOX-9 [Poecilia l...  <a href=#XP_014902658.1>687</a>     0.0   \n"+
"XP_007240551.1  PREDICTED: transcription factor Sox-9-A-like [Ast...  <a href=#XP_007240551.1>661</a>     0.0   \n"+
"XP_010974287.1  PREDICTED: transcription factor SOX-9 [Camelus dr...  <a href=#XP_010974287.1>659</a>     0.0   \n"+
"XP_014953896.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_014953896.1>619</a>     0.0   \n"+
"XP_011857245.1  PREDICTED: transcription factor SOX-9 [Mandrillus...  <a href=#XP_011857245.1>605</a>     0.0   \n"+
"XP_010719808.1  PREDICTED: transcription factor SOX-9 [Meleagris ...  <a href=#XP_010719808.1>591</a>     0.0   \n"+
"BAC06353.1  SOX9 longer form [Oryzias latipes]                        <a href=#BAC06353.1>589</a>     0.0   \n"+
"KTG34845.1  hypothetical protein cypCar_00020995 [Cyprinus carpio]    <a href=#KTG34845.1>575</a>     0.0   \n"+
"AFA46805.1  Sox9 [Gadus morhua]                                       <a href=#AFA46805.1>574</a>     0.0   \n"+
"XP_012673302.1  PREDICTED: transcription factor Sox-9-A-like [Clu...  <a href=#XP_012673302.1>559</a>     0.0   \n"+
"ETE65376.1  Transcription factor SOX-9, partial [Ophiophagus hannah]  <a href=#ETE65376.1>542</a>     0.0   \n"+
"ADJ96869.1  Sox9b [Clarias gariepinus]                                <a href=#ADJ96869.1>528</a>     0.0   \n"+
"XP_007099260.2  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_007099260.2>509</a>     2e-178\n"+
"ABC58685.1  HMG box protein SoxE3 [Petromyzon marinus]                <a href=#ABC58685.1>512</a>     1e-175\n"+
"ABQ44208.1  SRY-box containing gene 9, partial [Aspidoscelis inor...  <a href=#ABQ44208.1>497</a>     6e-173\n"+
"XP_015718433.1  PREDICTED: transcription factor SOX-10 [Coturnix ...  <a href=#XP_015718433.1>468</a>     4e-158\n"+
"KFQ49910.1  Transcription factor SOX-9, partial [Nestor notabilis]    <a href=#KFQ49910.1>452</a>     2e-156\n"+
"BAG11536.1  Sry-box protein 9 [Eptatretus burgeri]                    <a href=#BAG11536.1>451</a>     2e-152\n"+
"AAI70062.1  LOC398422 protein [Xenopus laevis]                        <a href=#AAI70062.1>449</a>     4e-152\n"+
"XP_015314502.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_015314502.1>439</a>     1e-149\n"+
"AGZ80879.1  Sox9a variant 6, partial [Carassius auratus ssp. 'Pen...  <a href=#AGZ80879.1>435</a>     7e-149\n"+
"AAG09815.1  HMG box transcription factor Sox9b [Danio rerio]          <a href=#AAG09815.1>432</a>     4e-146\n"+
"AAH04064.1  Sox9 protein, partial [Mus musculus]                      <a href=#AAH04064.1>421</a>     6e-144\n"+
"EHH25156.1  hypothetical protein EGK_08928, partial [Macaca mulatta]  <a href=#EHH25156.1>418</a>     2e-141\n"+
"XP_007622861.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_007622861.1>422</a>     1e-139\n"+
"XP_008492897.1  PREDICTED: transcription factor SOX-9 [Calypte anna]  <a href=#XP_008492897.1>413</a>     1e-139\n"+
"XP_014166731.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_014166731.1>414</a>     2e-139\n"+
"XP_014059241.1  PREDICTED: transcription factor Sox-10-like [Salm...  <a href=#XP_014059241.1>414</a>     5e-138\n"+
"AFX73410.1  transcription factor Sox9, partial [Salvelinus alpinus]   <a href=#AFX73410.1>401</a>     2e-136\n"+
"BAN66330.1  transcription factor, partial [Homo sapiens]              <a href=#BAN66330.1>400</a>     3e-136\n"+
"XP_016831152.1  PREDICTED: transcription factor SOX-9 isoform X1 ...  <a href=#XP_016831152.1>402</a>     2e-132\n"+
"BAG14376.1  SoxE family protein E3, partial [Lethenteron camtscha...  <a href=#BAG14376.1>394</a>     2e-131\n"+
"XP_006752033.1  PREDICTED: POU domain, class 3, transcription fac...  <a href=#XP_006752033.1>385</a>     2e-126\n"+
"XP_013986160.1  PREDICTED: transcription factor SOX-10 [Salmo salar]  <a href=#XP_013986160.1>379</a>     5e-124\n"+
"AAW69293.1  HMG box transcription factor Sox9b [Carassius auratus...  <a href=#AAW69293.1>373</a>     7e-123\n"+
"XP_017896058.1  PREDICTED: transcription factor SOX-8 [Capra hircus]  <a href=#XP_017896058.1>372</a>     6e-121\n"+
"XP_012678676.1  PREDICTED: transcription factor SOX-8-like [Clupe...  <a href=#XP_012678676.1>368</a>     4e-120\n"+
"XP_007901694.1  PREDICTED: transcription factor SOX-8 [Callorhinc...  <a href=#XP_007901694.1>364</a>     2e-119\n"+
"XP_005444177.1  PREDICTED: transcription factor SOX-8, partial [F...  <a href=#XP_005444177.1>362</a>     2e-119\n"+
"XP_006061803.1  PREDICTED: transcription factor SOX-8 [Bubalus bu...  <a href=#XP_006061803.1>368</a>     8e-119\n"+
"XP_015346099.1  PREDICTED: transcription factor SOX-8 [Marmota ma...  <a href=#XP_015346099.1>361</a>     2e-118\n"+
"XP_010946986.1  PREDICTED: transcription factor SOX-9-like, parti...  <a href=#XP_010946986.1>354</a>     3e-118\n"+
"DAA15743.1  SRY (sex determining region Y)-box 8-like [Bos taurus]    <a href=#DAA15743.1>371</a>     8e-118\n"+
"XP_008568803.1  PREDICTED: transcription factor SOX-8 [Galeopteru...  <a href=#XP_008568803.1>376</a>     2e-117\n"+
"XP_010897926.2  PREDICTED: transcription factor Sox-8 isoform X1 ...  <a href=#XP_010897926.2>358</a>     2e-116\n"+
"XP_016379878.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_016379878.1>357</a>     2e-116\n"+
"BAB71726.1  Sry-related transcription factor Sox9, partial [Rattu...  <a href=#BAB71726.1>346</a>     5e-116\n"+
"AAB49282.1  transcription factor Sox-M, partial [Mus musculus]        <a href=#AAB49282.1>359</a>     6e-116\n"+
"XP_011602318.1  PREDICTED: transcription factor SOX-9-like [Takif...  <a href=#XP_011602318.1>342</a>     9e-113\n"+
"XP_006637076.2  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_006637076.2>347</a>     1e-112\n"+
"CCP19140.1  SRY-related box 8, partial [Latimeria menadoensis]        <a href=#CCP19140.1>340</a>     1e-112\n"+
"XP_003417746.1  PREDICTED: transcription factor SOX-8 [Loxodonta ...  <a href=#XP_003417746.1>353</a>     5e-112\n"+
"ABB02374.2  Sox8, partial [Salmo salar]                               <a href=#ABB02374.2>337</a>     2e-109\n"+
"KFV48233.1  Transcription factor SOX-10, partial [Tyto alba]          <a href=#KFV48233.1>332</a>     6e-109\n"+
"ACZ54381.1  SRY-box 9 protein, partial [Monodelphis domestica]        <a href=#ACZ54381.1>327</a>     8e-109\n"+
"XP_010171101.1  PREDICTED: transcription factor SOX-9-like, parti...  <a href=#XP_010171101.1>329</a>     2e-108\n"+
"EMP27032.1  Transcription factor SOX-10 [Chelonia mydas]              <a href=#EMP27032.1>336</a>     3e-108\n"+
"ABG89133.1  sox9b, partial [Kryptolebias marmoratus]                  <a href=#ABG89133.1>325</a>     3e-107\n"+
"XP_012790332.1  PREDICTED: transcription factor SOX-9 [Sorex aran...  <a href=#XP_012790332.1>326</a>     1e-106\n"+
"XP_016157275.1  PREDICTED: transcription factor SOX-8 [Ficedula a...  <a href=#XP_016157275.1>330</a>     8e-106\n"+
"BAS29568.1  SRY (sex determining region Y)-box9, partial [Homo sa...  <a href=#BAS29568.1>312</a>     8e-103\n"+
"AHK05950.1  Sox8 [Plecoglossus altivelis]                             <a href=#AHK05950.1>321</a>     1e-101\n"+
"CBN81184.1  Transcription factor Sox-8 [Dicentrarchus labrax]         <a href=#CBN81184.1>318</a>     1e-100\n"+
"ACZ65967.1  Sox8b [Misgurnus anguillicaudatus]                        <a href=#ACZ65967.1>316</a>     1e-100\n"+
"XP_004449420.1  PREDICTED: transcription factor SOX-8 [Dasypus no...  <a href=#XP_004449420.1>315</a>     3e-100\n"+
"XP_014959333.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_014959333.1>322</a>     2e-99 \n"+
"XP_006745230.1  PREDICTED: transcription factor SOX-9-like [Lepto...  <a href=#XP_006745230.1>307</a>     3e-99 \n"+
"XP_010776021.1  PREDICTED: transcription factor Sox-8-like [Notot...  <a href=#XP_010776021.1>310</a>     5e-98 \n"+
"XP_006146498.1  PREDICTED: transcription factor SOX-8 [Tupaia chi...  <a href=#XP_006146498.1>310</a>     5e-97 \n"+
"KTG34073.1  hypothetical protein cypCar_00009421 [Cyprinus carpio]    <a href=#KTG34073.1>305</a>     8e-97 \n"+
"AAO39385.1  transcription factor sox-9, partial [Chelydra serpent...  <a href=#AAO39385.1>294</a>     4e-95 \n"+
"XP_003779598.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_003779598.1>300</a>     3e-94 \n"+
"XP_012590517.1  PREDICTED: transcription factor SOX-10 [Condylura...  <a href=#XP_012590517.1>296</a>     4e-93 \n"+
"XP_014013894.1  PREDICTED: transcription factor SOX-8 isoform X1 ...  <a href=#XP_014013894.1>298</a>     5e-93 \n"+
"XP_005955733.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_005955733.1>291</a>     2e-89 \n"+
"XP_006174991.1  PREDICTED: transcription factor SOX-10 [Camelus f...  <a href=#XP_006174991.1>284</a>     2e-89 \n"+
"XP_003961594.1  PREDICTED: transcription factor SOX-8 isoform X1 ...  <a href=#XP_003961594.1>288</a>     3e-89 \n"+
"AAX73357.1  Sox8 [Danio rerio]                                        <a href=#AAX73357.1>282</a>     2e-88 \n"+
"EEN51626.1  hypothetical protein BRAFLDRAFT_200721, partial [Bran...  <a href=#EEN51626.1>270</a>     2e-85 \n"+
"XP_006220134.1  PREDICTED: transcription factor SOX-9, partial [V...  <a href=#XP_006220134.1>265</a>     4e-85 \n"+
"ACN58719.1  Transcription factor SOX-9, partial [Salmo salar]         <a href=#ACN58719.1>267</a>     2e-84 \n"+
"XP_012724684.1  PREDICTED: transcription factor SOX-8 [Fundulus h...  <a href=#XP_012724684.1>275</a>     3e-84 \n"+
"XP_002737877.2  PREDICTED: transcription factor Sox-9-like [Sacco...  <a href=#XP_002737877.2>273</a>     1e-83 \n"+
"XP_012407034.1  PREDICTED: transcription factor SOX-10 [Sarcophil...  <a href=#XP_012407034.1>275</a>     2e-83 \n"+
"XP_014677044.1  PREDICTED: transcription factor SOX-9-like [Priap...  <a href=#XP_014677044.1>273</a>     2e-83 \n"+
"XP_015391817.1  PREDICTED: transcription factor SOX-10 [Panthera ...  <a href=#XP_015391817.1>272</a>     3e-83 \n"+
"AFJ05115.1  transcription factor SOX-9, partial [Taeniopygia gutt...  <a href=#AFJ05115.1>261</a>     3e-82 \n"+
"KPP70379.1  transcription factor Sox-9-A-like [Scleropages formosus]  <a href=#KPP70379.1>264</a>     1e-81 \n"+
"XP_009886858.1  PREDICTED: transcription factor SOX-8, partial [C...  <a href=#XP_009886858.1>263</a>     4e-81 \n"+
"XP_017509598.1  PREDICTED: transcription factor SOX-9-like [Manis...  <a href=#XP_017509598.1>257</a>     7e-80 \n"+
"XP_004063516.1  PREDICTED: transcription factor SOX-10, partial [...  <a href=#XP_004063516.1>255</a>     3e-79 \n"+
"XP_015819190.1  PREDICTED: transcription factor SOX-8 [Nothobranc...  <a href=#XP_015819190.1>260</a>     9e-79 \n"+
"ACZ54382.1  SRY-box 10 protein, partial [Monodelphis domestica]       <a href=#ACZ54382.1>251</a>     1e-78 \n"+
"XP_013381128.1  PREDICTED: transcription factor Sox-10-like [Ling...  <a href=#XP_013381128.1>254</a>     3e-78 \n"+
"XP_009895648.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_009895648.1>252</a>     4e-78 \n"+
"XP_013381127.1  PREDICTED: transcription factor SOX-9-like [Lingu...  <a href=#XP_013381127.1>258</a>     1e-77 \n"+
"AIE16096.1  transcription faxtor Sox9 [Pinctada margaritifera]        <a href=#AIE16096.1>257</a>     3e-77 \n"+
"XP_010967835.1  PREDICTED: transcription factor SOX-9, partial [C...  <a href=#XP_010967835.1>244</a>     7e-77 \n"+
"XP_014980744.1  PREDICTED: transcription factor SOX-8 [Macaca mul...  <a href=#XP_014980744.1>252</a>     8e-77 \n"+
"XP_017923109.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_017923109.1>251</a>     3e-76 \n"+
"AAC24565.1  Dominant megacolon mutant Sox-10 protein [Mus musculus]   <a href=#AAC24565.1>248</a>     4e-76 \n"+
"XP_005591840.1  PREDICTED: transcription factor SOX-8 [Macaca fas...  <a href=#XP_005591840.1>246</a>     3e-75 \n"+
"XP_010337512.1  PREDICTED: transcription factor SOX-8 [Saimiri bo...  <a href=#XP_010337512.1>252</a>     3e-75 \n"+
"EDM03938.1  SRY-box containing gene 8 (predicted), isoform CRA_a ...  <a href=#EDM03938.1>243</a>     7e-75 \n"+
"XP_009083174.1  PREDICTED: transcription factor SOX-8, partial [A...  <a href=#XP_009083174.1>239</a>     9e-75 \n"+
"XP_004310634.1  PREDICTED: transcription factor SOX-8 [Tursiops t...  <a href=#XP_004310634.1>245</a>     8e-74 \n"+
"AAW34332.1  SoxE1 [Petromyzon marinus]                                <a href=#AAW34332.1>252</a>     8e-74 \n"+
"AGL08099.1  SoxE [Sepia officinalis]                                  <a href=#AGL08099.1>243</a>     4e-73 \n"+
"EDL22429.1  SRY-box containing gene 8, isoform CRA_a [Mus musculus]   <a href=#EDL22429.1>241</a>     7e-73 \n"+
"XP_013091187.1  PREDICTED: transcription factor Sox-10-like [Biom...  <a href=#XP_013091187.1>246</a>     7e-73 \n"+
"XP_016120675.1  PREDICTED: transcription factor SOX-10-like, part...  <a href=#XP_016120675.1>241</a>     1e-72 \n"+
"CAF87551.1  unnamed protein product, partial [Tetraodon nigroviri...  <a href=#CAF87551.1>239</a>     1e-72 \n"+
"KPP65044.1  hypothetical protein Z043_116558 [Scleropages formosus]   <a href=#KPP65044.1>236</a>     2e-72 \n"+
"XP_011601849.1  PREDICTED: transcription factor SOX-10 isoform X3...  <a href=#XP_011601849.1>237</a>     2e-70 \n"+
"XP_013777180.1  PREDICTED: transcription factor Sox-8-like [Limul...  <a href=#XP_013777180.1>241</a>     2e-70 \n"+
"ACU12333.1  Sox9 isoform 17, partial [Crocodylus palustris]           <a href=#ACU12333.1>229</a>     3e-70 \n"+
"ABC58684.1  HMG box protein SoxE2 [Petromyzon marinus]                <a href=#ABC58684.1>239</a>     2e-69 \n"+
"ABA02365.1  sox family protein E1 [Nematostella vectensis]            <a href=#ABA02365.1>233</a>     5e-69 \n"+
"CDQ74372.1  unnamed protein product [Oncorhynchus mykiss]             <a href=#CDQ74372.1>237</a>     7e-69 \n"+
"XP_005886936.1  PREDICTED: transcription factor SOX-8 [Bos mutus]     <a href=#XP_005886936.1>245</a>     1e-68 \n"+
"KFM81451.1  Transcription factor Sox-9, partial [Stegodyphus mimo...  <a href=#KFM81451.1>228</a>     3e-68 \n"+
"XP_013789847.1  PREDICTED: transcription factor Sox-9-B-like [Lim...  <a href=#XP_013789847.1>233</a>     1e-67 \n"+
"KPP60376.1  transcription factor SOX-8-like [Scleropages formosus]    <a href=#KPP60376.1>226</a>     2e-66 \n"+
"XP_009940020.1  PREDICTED: transcription factor SOX-9 [Opisthocom...  <a href=#XP_009940020.1>219</a>     2e-66 \n"+
"KXJ11873.1  Transcription factor SOX-9 [Exaiptasia pallida]           <a href=#KXJ11873.1>219</a>     2e-63 \n"+
"XP_002122233.2  PREDICTED: uncharacterized protein LOC445804 [Cio...  <a href=#XP_002122233.2>228</a>     3e-63 \n"+
"ELU17008.1  hypothetical protein CAPTEDRAFT_175609 [Capitella tel...  <a href=#ELU17008.1>218</a>     3e-62 \n"+
"AAO39401.1  transcription factor sox-9, partial [Ornithorhynchus ...  <a href=#AAO39401.1>206</a>     2e-61 \n"+
"CAF96993.1  unnamed protein product [Tetraodon nigroviridis]          <a href=#CAF96993.1>214</a>     2e-61 \n"+
"XP_005102100.1  PREDICTED: transcription factor Sox-10-like [Aply...  <a href=#XP_005102100.1>216</a>     2e-60 \n"+
"ERE68692.1  transcription factor SOX-8 [Cricetulus griseus]           <a href=#ERE68692.1>209</a>     3e-60 \n"+
"XP_015762367.1  PREDICTED: transcription factor SOX-9-like [Acrop...  <a href=#XP_015762367.1>211</a>     7e-60 \n"+
"XP_010197492.1  PREDICTED: transcription factor SOX-8, partial [C...  <a href=#XP_010197492.1>204</a>     7e-60 \n"+
"XP_008692170.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_008692170.1>201</a>     4e-59 \n"+
"AAH78333.1  Sox10 protein [Danio rerio]                               <a href=#AAH78333.1>199</a>     6e-59 \n"+
"XP_013787422.1  PREDICTED: transcription factor Sox-10-like [Limu...  <a href=#XP_013787422.1>209</a>     1e-58 \n"+
"ALM01447.1  SoxE [Limulus polyphemus]                                 <a href=#ALM01447.1>206</a>     3e-58 \n"+
"ETE59020.1  Transcription factor SOX-8, partial [Ophiophagus hannah]  <a href=#ETE59020.1>200</a>     2e-57 \n"+
"ABB45787.1  transcription factor sox9, partial [Oreochromis aureus]   <a href=#ABB45787.1>191</a>     3e-56 \n"+
"BAJ76658.1  transcription factor SoxE, partial [Branchiostoma bel...  <a href=#BAJ76658.1>198</a>     5e-56 \n"+
"XP_012860937.1  PREDICTED: transcription factor SOX-8 [Echinops t...  <a href=#XP_012860937.1>204</a>     5e-56 \n"+
"KTF90817.1  hypothetical protein cypCar_00015203 [Cyprinus carpio]    <a href=#KTF90817.1>196</a>     6e-55 \n"+
"AAO39392.1  transcription factor sox-9, partial [Orycteropus afer]    <a href=#AAO39392.1>189</a>     2e-54 \n"+
"XP_017780683.1  PREDICTED: transcription factor Sox-9-A-like [Nic...  <a href=#XP_017780683.1>195</a>     3e-54 \n"+
"AEH57091.1  SoxE, partial [Bugula neritina]                           <a href=#AEH57091.1>189</a>     5e-54 \n"+
"ACU12298.1  Sox9 isoform 2, partial [Mus musculus]                    <a href=#ACU12298.1>186</a>     1e-53 \n"+
"ALG35687.1  SoxE [Lytechinus variegatus]                              <a href=#ALG35687.1>196</a>     1e-53 \n"+
"ALE14467.1  transcription factor sox8, partial [Scophthalmus maxi...  <a href=#ALE14467.1>183</a>     2e-53 \n"+
"XP_018331741.1  PREDICTED: transcription factor SOX-9-like [Agril...  <a href=#XP_018331741.1>192</a>     3e-53 \n"+
"EHH31284.1  Transcription factor SOX-8, partial [Macaca mulatta]      <a href=#EHH31284.1>189</a>     3e-53 \n"+
"XP_012262254.1  PREDICTED: putative uncharacterized protein DDB_G...  <a href=#XP_012262254.1>199</a>     4e-53 \n"+
"BAR45483.1  SRY-box containing protein 9, partial [Seriola quinqu...  <a href=#BAR45483.1>183</a>     9e-53 \n"+
"4EUW|A  Chain A, Crystal Structure Of A Hmg Domain Of Transcr...      <a href=#4EUW_A>179</a>     3e-52 \n"+
"AAK50634.1  sox9 protein, partial [Oryzias latipes]                   <a href=#AAK50634.1>183</a>     3e-52 \n"+
"XP_015521624.1  PREDICTED: transcription factor Sox-9-B-like [Neo...  <a href=#XP_015521624.1>191</a>     5e-52 \n"+
"XP_012866732.1  PREDICTED: transcription factor SOX-8 [Dipodomys ...  <a href=#XP_012866732.1>189</a>     6e-52 \n"+
"XP_015833813.1  PREDICTED: transcription factor Sox-10 [Tribolium...  <a href=#XP_015833813.1>187</a>     1e-51 \n"+
"XP_002186765.3  PREDICTED: transcription factor SOX-9-like, parti...  <a href=#XP_002186765.3>180</a>     1e-51 \n"+
"XP_010143871.1  PREDICTED: transcription factor SOX-8-like, parti...  <a href=#XP_010143871.1>179</a>     3e-51 \n"+
"KGL96169.1  Transcription factor SOX-8, partial [Charadrius vocif...  <a href=#KGL96169.1>177</a>     7e-51 \n"+
"XP_006166311.2  PREDICTED: transcription factor SOX-10, partial [...  <a href=#XP_006166311.2>184</a>     1e-50 \n"+
"XP_015914452.1  PREDICTED: transcription factor SOX-8-like [Paras...  <a href=#XP_015914452.1>188</a>     1e-50 \n"+
"XP_015783447.1  PREDICTED: transcription factor SOX-9-like isofor...  <a href=#XP_015783447.1>192</a>     1e-50 \n"+
"XP_014387411.1  PREDICTED: transcription factor SOX-1 [Myotis bra...  <a href=#XP_014387411.1>181</a>     2e-50 \n"+
"AAB71657.1  SOX9, partial [Sus scrofa]                                <a href=#AAB71657.1>174</a>     2e-50 \n"+
"XP_013778136.1  PREDICTED: transcription factor Sox-8-like [Limul...  <a href=#XP_013778136.1>186</a>     3e-50 \n"+
"XP_015783378.1  PREDICTED: transcription factor Sox-9-like [Tetra...  <a href=#XP_015783378.1>190</a>     4e-50 \n"+
"XP_014243400.1  PREDICTED: transcription factor Sox-8-like isofor...  <a href=#XP_014243400.1>181</a>     4e-50 \n"+
"XP_017798537.1  PREDICTED: transcription factor SOX-9-like [Habro...  <a href=#XP_017798537.1>183</a>     7e-50 \n"+
"EDV27926.1  hypothetical protein TRIADDRAFT_21755, partial [Trich...  <a href=#EDV27926.1>174</a>     2e-49 \n"+
"KOX79192.1  Transcription factor Sox-10 [Melipona quadrifasciata]     <a href=#KOX79192.1>188</a>     3e-49 \n"+
"BAK69337.1  SoxE protein, partial [Balanoglossus simodensis]          <a href=#BAK69337.1>174</a>     6e-49 \n"+
"AHG06472.1  SRY-box containing protein 9, partial [Lates calcarifer]  <a href=#AHG06472.1>171</a>     6e-49 \n"+
"CBY02482.1  putative SRY (sex determining region Y)-box 9, partia...  <a href=#CBY02482.1>170</a>     7e-49 \n"+
"ABN50067.1  SRY-box containing 9, partial [Capra hircus]              <a href=#ABN50067.1>176</a>     7e-49 \n"+
"BAR73294.1  Sox9 [Peronella japonica]                                 <a href=#BAR73294.1>182</a>     1e-48 \n"+
"XP_016402817.1  PREDICTED: transcription factor Sox-8-like, parti...  <a href=#XP_016402817.1>169</a>     4e-48 \n"+
"ACU12311.1  Sox9 isoform 15, partial [Mus musculus]                   <a href=#ACU12311.1>169</a>     5e-48 \n"+
"XP_013863558.1  PREDICTED: transcription factor Sox-9-A-like, par...  <a href=#XP_013863558.1>172</a>     7e-48 \n"+
"XP_011302474.1  PREDICTED: transcription factor Sox-10-like [Fopi...  <a href=#XP_011302474.1>178</a>     9e-48 \n"+
"XP_003245920.1  PREDICTED: transcription factor Sox-10 [Acyrthosi...  <a href=#XP_003245920.1>174</a>     3e-47 \n"+
"XP_008213434.1  PREDICTED: transcription factor SOX-9-like [Nason...  <a href=#XP_008213434.1>174</a>     4e-47 \n"+
"AHG56859.1  sox9b, partial [Clarias batrachus]                        <a href=#AHG56859.1>168</a>     7e-47 \n"+
"XP_011494181.1  PREDICTED: transcription factor Sox-21-B [Ceratos...  <a href=#XP_011494181.1>172</a>     1e-46 \n"+
"XP_003702900.1  PREDICTED: transcription factor Sox-8-like [Megac...  <a href=#XP_003702900.1>172</a>     2e-46 \n"+
"XP_015588627.1  PREDICTED: transcription factor Sox-10-like [Ceph...  <a href=#XP_015588627.1>172</a>     2e-46 \n"+
"XP_014931793.1  PREDICTED: transcription factor SOX-9, partial [A...  <a href=#XP_014931793.1>167</a>     2e-46 \n"+
"XP_017767188.1  PREDICTED: transcription factor Sox-10-like isofo...  <a href=#XP_017767188.1>174</a>     3e-46 \n"+
"XP_010408412.1  PREDICTED: transcription factor SOX-9 [Corvus cor...  <a href=#XP_010408412.1>166</a>     3e-46 \n"+
"XP_012271640.1  PREDICTED: transcription factor SOX-10-like [Orus...  <a href=#XP_012271640.1>170</a>     4e-46 \n"+
"XP_008559241.1  PREDICTED: sex-determining region Y protein [Micr...  <a href=#XP_008559241.1>171</a>     5e-46 \n"+
"XP_014228418.1  PREDICTED: transcription factor SOX-8-like, parti...  <a href=#XP_014228418.1>166</a>     6e-46 \n"+
"XP_008470663.1  PREDICTED: transcription factor Sox-10 [Diaphorin...  <a href=#XP_008470663.1>172</a>     8e-46 \n"+
"XP_011347627.1  PREDICTED: transcription factor Sox-1a-like [Cera...  <a href=#XP_011347627.1>172</a>     1e-45 \n"+
"XP_012262253.1  PREDICTED: transcription factor Sox-8-like [Athal...  <a href=#XP_012262253.1>171</a>     1e-45 \n"+
"XP_014211338.1  PREDICTED: sex-determining region Y protein-like ...  <a href=#XP_014211338.1>171</a>     1e-45 \n"+
"XP_011302468.1  PREDICTED: transcription factor Sox-17-alpha-B-li...  <a href=#XP_011302468.1>169</a>     3e-45 \n"+
"KKF09025.1  Transcription factor SOX-10 [Larimichthys crocea]         <a href=#KKF09025.1>164</a>     4e-45 \n"+
"XP_008559245.1  PREDICTED: transcription factor Sox-8 [Micropliti...  <a href=#XP_008559245.1>172</a>     4e-45 \n"+
"EZA48830.1  Transcription factor Sox-9-B [Cerapachys biroi]           <a href=#EZA48830.1>168</a>     6e-45 \n"+
"XP_015800813.1  PREDICTED: transcription factor SOX-10-like, part...  <a href=#XP_015800813.1>167</a>     1e-44 \n"+
"ACU12306.1  Sox9 isoform 10, partial [Mus musculus]                   <a href=#ACU12306.1>159</a>     2e-44 \n"+
"XP_001604913.2  PREDICTED: transcription factor Sox-9-B isoform X...  <a href=#XP_001604913.2>170</a>     2e-44 \n"+
"XP_003741216.1  PREDICTED: transcription factor Sox-9-A-like [Met...  <a href=#XP_003741216.1>163</a>     3e-44 \n"+
"KOC68738.1  Transcription factor Sox-9-B [Habropoda laboriosa]        <a href=#KOC68738.1>165</a>     5e-44 \n"+
"ACU12319.1  Sox9 isoform 3, partial [Crocodylus palustris]            <a href=#ACU12319.1>159</a>     5e-44 \n"+
"XP_014612515.1  PREDICTED: transcription factor Sox-8-like [Polis...  <a href=#XP_014612515.1>165</a>     1e-43 \n"+
"XP_014197099.1  PREDICTED: transcription factor SOX-8 [Pan paniscus]  <a href=#XP_014197099.1>165</a>     7e-43 \n"+
"KTF90362.1  hypothetical protein cypCar_00036192, partial [Cyprin...  <a href=#KTF90362.1>160</a>     8e-43 \n"+
"JAS10739.1  hypothetical protein g.162, partial [Clastoptera ariz...  <a href=#JAS10739.1>156</a>     3e-42 \n"+
"KOX79193.1  Transcription factor Sox-9-B [Melipona quadrifasciata]    <a href=#KOX79193.1>162</a>     1e-41 \n"+
"XP_014228428.1  PREDICTED: transcription factor Sox-9-B-like [Tri...  <a href=#XP_014228428.1>165</a>     1e-41 \n"+
"XP_018027556.1  PREDICTED: transcription factor Sox-8-like [Hyale...  <a href=#XP_018027556.1>159</a>     2e-41 \n"+
"AGH69793.1  Sox9b-like protein, partial [Anoplopoma fimbria]          <a href=#AGH69793.1>152</a>     3e-41 \n"+
"XP_014271239.1  PREDICTED: transcription factor SOX-9-like isofor...  <a href=#XP_014271239.1>156</a>     9e-41 \n"+
"EZA48828.1  Transcription factor Sox-8 [Cerapachys biroi]             <a href=#EZA48828.1>159</a>     1e-40 \n"+
"XP_006636968.1  PREDICTED: transcription factor SOX-10, partial [...  <a href=#XP_006636968.1>151</a>     1e-40 \n"+
"OAF68982.1  hypothetical protein A3Q56_03272 [Intoshia linei]         <a href=#OAF68982.1>156</a>     2e-40 \n"+
"ACU12325.1  Sox9 isoform 9, partial [Crocodylus palustris]            <a href=#ACU12325.1>148</a>     2e-40 \n"+
"XP_012156196.1  PREDICTED: putative GPI-anchored protein PB15E9.0...  <a href=#XP_012156196.1>163</a>     2e-40 \n"+
"XP_011878279.1  PREDICTED: transcription factor SOX-9-like isofor...  <a href=#XP_011878279.1>157</a>     2e-40 \n"+
"AIU56789.1  Sox9, partial [Huso huso]                                 <a href=#AIU56789.1>148</a>     3e-40 \n"+
"XP_003741217.1  PREDICTED: uncharacterized protein LOC100903215 [...  <a href=#XP_003741217.1>155</a>     3e-40 \n"+
"EEB17538.1  Sex-determining region Y protein, putative [Pediculus...  <a href=#EEB17538.1>154</a>     4e-40 \n"+
"AAY54014.1  Sox10a, partial [Haplochromis burtoni]                    <a href=#AAY54014.1>148</a>     5e-40 \n"+
"XP_015521625.1  PREDICTED: transcription factor SOX-8-like [Neodi...  <a href=#XP_015521625.1>155</a>     8e-40 \n"+
"XP_011212520.1  PREDICTED: mucin-21 [Bactrocera dorsalis]             <a href=#XP_011212520.1>161</a>     9e-40 \n"+
"JAN80589.1  Transcription factor Sox-9-A [Daphnia magna]              <a href=#JAN80589.1>159</a>     3e-39 \n"+
"ACF06318.1  Sox9, partial [Oncorhynchus mykiss]                       <a href=#ACF06318.1>144</a>     5e-39 \n"+
"XP_017037366.1  PREDICTED: transcription factor SOX-8 [Drosophila...  <a href=#XP_017037366.1>156</a>     9e-39 \n"+
"EDW82976.2  uncharacterized protein Dwil_GK22609 [Drosophila will...  <a href=#EDW82976.2>154</a>     2e-38 \n"+
"AAO39384.1  transcription factor sox-9, partial [Turdus merula]       <a href=#AAO39384.1>144</a>     3e-38 \n"+
"ACU12329.1  Sox9 isoform 13, partial [Crocodylus palustris]           <a href=#ACU12329.1>143</a>     5e-38 \n"+
"ACA50927.1  Sox9, partial [Salmo salar]                               <a href=#ACA50927.1>141</a>     6e-38 \n"+
"EDW59041.2  uncharacterized protein Dvir_GJ10502 [Drosophila viri...  <a href=#EDW59041.2>154</a>     7e-38 \n"+
"ACU12322.1  Sox9 isoform 6, partial [Crocodylus palustris]            <a href=#ACU12322.1>145</a>     7e-38 \n"+
"ALC48024.1  Sox100B [Drosophila busckii]                              <a href=#ALC48024.1>153</a>     8e-38 \n"+
"XP_017039353.1  PREDICTED: transcription factor Sox-10 [Drosophil...  <a href=#XP_017039353.1>153</a>     8e-38 \n"+
"EAL26711.2  uncharacterized protein Dpse_GA13810, isoform A [Dros...  <a href=#EAL26711.2>152</a>     2e-37 \n"+
"EDV90820.1  GH13971 [Drosophila grimshawi]                            <a href=#EDV90820.1>152</a>     2e-37 \n"+
"XP_005179606.2  PREDICTED: uncharacterized protein LOC101900714, ...  <a href=#XP_005179606.2>153</a>     6e-37 \n"+
"KDR20036.1  Transcription factor SOX-8 [Zootermopsis nevadensis]      <a href=#KDR20036.1>146</a>     6e-37 \n"+
"BAH66375.1  SRY-box containing gene 9 homologue, partial [Pelodis...  <a href=#BAH66375.1>137</a>     9e-37 \n"+
"XP_015796225.1  PREDICTED: transcription factor Sox-10-like, part...  <a href=#XP_015796225.1>139</a>     2e-36 \n"+
"ADZ96251.1  SoxE [Bombyx mori]                                        <a href=#ADZ96251.1>141</a>     3e-36 \n"+
"XP_013101706.1  PREDICTED: uncharacterized protein LOC106083315 [...  <a href=#XP_013101706.1>151</a>     4e-36 \n"+
"AAY54016.1  Sox10b, partial [Haplochromis burtoni]                    <a href=#AAY54016.1>137</a>     4e-36 \n"+
"XP_008695278.1  PREDICTED: transcription factor SOX-8, partial [U...  <a href=#XP_008695278.1>139</a>     6e-36 \n"+
"AIA23790.1  Sox3 [Mnemiopsis leidyi]                                  <a href=#AIA23790.1>145</a>     2e-35 \n"+
"AIA23791.1  Sox4 [Mnemiopsis leidyi]                                  <a href=#AIA23791.1>145</a>     2e-35 \n"+
"ABN58458.1  SoxE, partial [Branchiostoma lanceolatum]                 <a href=#ABN58458.1>135</a>     2e-35 \n"+
"XP_017088795.1  PREDICTED: transcription factor SOX-4 isoform X1 ...  <a href=#XP_017088795.1>146</a>     3e-35 \n"+
"XP_015138178.1  PREDICTED: transcription factor SOX-17-like [Gall...  <a href=#XP_015138178.1>143</a>     4e-35 \n"+
"AGZ62960.1  SRY-box 9, partial [Homo sapiens]                         <a href=#AGZ62960.1>135</a>     8e-35 \n"+
"EDO42788.1  predicted protein, partial [Nematostella vectensis]       <a href=#EDO42788.1>132</a>     1e-34 \n"+
"XP_018027588.1  PREDICTED: transcription factor SOX-8-like [Hyale...  <a href=#XP_018027588.1>145</a>     2e-34 \n"+
"ACU12310.1  Sox9 isoform 14, partial [Mus musculus]                   <a href=#ACU12310.1>132</a>     2e-34 \n"+
"XP_013792516.1  PREDICTED: transcription factor Sox-8-like, parti...  <a href=#XP_013792516.1>132</a>     4e-34 \n"+
"KXJ18409.1  Transcription factor Sox-8 [Exaiptasia pallida]           <a href=#KXJ18409.1>140</a>     7e-34 \n"+
"ESN97653.1  hypothetical protein HELRODRAFT_147226, partial [Helo...  <a href=#ESN97653.1>130</a>     8e-34 \n"+
"ELK28442.1  Transcription factor SOX-8 [Myotis davidii]               <a href=#ELK28442.1>137</a>     1e-33 \n"+
"ACU12332.1  Sox 9 isoform 16, partial [Crocodylus palustris]          <a href=#ACU12332.1>132</a>     2e-33 \n"+
"AIA23793.1  Sox6 [Mnemiopsis leidyi]                                  <a href=#AIA23793.1>138</a>     2e-33 \n"+
"AAH60612.1  Sox17 protein [Mus musculus]                              <a href=#AAH60612.1>132</a>     2e-33 \n"+
"KQK84642.1  transcription factor SOX-17 [Amazona aestiva]             <a href=#KQK84642.1>132</a>     3e-33 \n"+
"XP_009098993.1  PREDICTED: transcription factor SOX-17-like, part...  <a href=#XP_009098993.1>132</a>     3e-33 \n"+
"BAS29567.1  SRY (sex determining region Y)-box9, partial [Homo sa...  <a href=#BAS29567.1>127</a>     5e-33 \n"+
"CAP40305.1  Xsox17-alpha1 protein [Xenopus gilli]                     <a href=#CAP40305.1>133</a>     5e-33 \n"+
"XP_010001878.1  PREDICTED: transcription factor SOX-8 [Chaetura p...  <a href=#XP_010001878.1>132</a>     5e-33 \n"+
"XP_015472439.1  PREDICTED: transcription factor SOX-17, partial [...  <a href=#XP_015472439.1>134</a>     9e-33 \n"+
"XP_005993498.1  PREDICTED: transcription factor SOX-17 [Latimeria...  <a href=#XP_005993498.1>136</a>     1e-32 \n"+
"ESO96755.1  hypothetical protein LOTGIDRAFT_88815, partial [Lotti...  <a href=#ESO96755.1>126</a>     1e-32 \n"+
"KFP27629.1  Transcription factor SOX-10, partial [Colius striatus]    <a href=#KFP27629.1>129</a>     2e-32 \n"+
"XP_015758495.1  PREDICTED: transcription factor SOX-1-like [Acrop...  <a href=#XP_015758495.1>136</a>     3e-32 \n"+
"KQK84643.1  transcription factor SOX-17-like protein [Amazona aes...  <a href=#KQK84643.1>132</a>     3e-32 \n"+
"XP_005479360.1  PREDICTED: transcription factor SOX-17-like [Zono...  <a href=#XP_005479360.1>135</a>     3e-32 \n"+
"AEU10962.1  SRY-box containing protein 10, partial [Ceratotherium...  <a href=#AEU10962.1>129</a>     3e-32 \n"+
"KFM58735.1  Transcription factor Sox-9-B, partial [Stegodyphus mi...  <a href=#KFM58735.1>125</a>     1e-31 \n"+
"XP_015743638.1  PREDICTED: transcription factor SOX-17-like [Pyth...  <a href=#XP_015743638.1>130</a>     1e-31 \n"+
"ABS89291.1  SRY sex determining region Y-box 9, partial [Trachemy...  <a href=#ABS89291.1>124</a>     2e-31 \n"+
"Q8AWH3.1  RecName: Full=Transcription factor Sox-17-alpha; Short=...  <a href=#Q8AWH3.1>132</a>     2e-31 \n"+
"XP_004175324.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_004175324.1>134</a>     2e-31 \n"+
"ACH73250.1  sox7/17 protein [Saccoglossus kowalevskii]                <a href=#ACH73250.1>134</a>     3e-31 \n"+
"EEC11790.1  sox10 protein, putative [Ixodes scapularis]               <a href=#EEC11790.1>125</a>     4e-31 \n"+
"EEB17535.1  sox9, putative [Pediculus humanus corporis]               <a href=#EEB17535.1>125</a>     4e-31 \n"+
"XP_012676760.1  PREDICTED: transcription factor SOX-17 [Clupea ha...  <a href=#XP_012676760.1>133</a>     5e-31 \n"+
"XP_005301251.1  PREDICTED: transcription factor SOX-17-like [Chry...  <a href=#XP_005301251.1>131</a>     5e-31 \n"+
"EDO44142.1  predicted protein [Nematostella vectensis]                <a href=#EDO44142.1>130</a>     5e-31 \n"+
"XP_001368625.1  PREDICTED: transcription factor SOX-17-like [Mono...  <a href=#XP_001368625.1>132</a>     6e-31 \n"+
"XP_013908416.1  PREDICTED: transcription factor SOX-17 [Thamnophi...  <a href=#XP_013908416.1>131</a>     6e-31 \n"+
"AAH86959.1  SRY-box containing gene 17 [Danio rerio]                  <a href=#AAH86959.1>131</a>     8e-31 \n"+
"ACF33141.1  SoxC [Acropora millepora]                                 <a href=#ACF33141.1>128</a>     1e-30 \n"+
"Q6F2F0.2  RecName: Full=Transcription factor Sox-17-beta.3; AltNa...  <a href=#Q6F2F0.2>130</a>     1e-30 \n"+
"XP_007889185.1  PREDICTED: transcription factor SOX-17 [Callorhin...  <a href=#XP_007889185.1>131</a>     1e-30 \n"+
"XP_006633984.1  PREDICTED: transcription factor SOX-17 [Lepisoste...  <a href=#XP_006633984.1>130</a>     1e-30 \n"+
"XP_007231138.1  PREDICTED: transcription factor Sox-17-alpha-A [A...  <a href=#XP_007231138.1>131</a>     2e-30 \n"+
"KPP57227.1  transcription factor Sox-17-alpha-like [Scleropages f...  <a href=#KPP57227.1>130</a>     2e-30 \n"+
"XP_003224366.1  PREDICTED: transcription factor SOX-17 [Anolis ca...  <a href=#XP_003224366.1>129</a>     2e-30 \n"+
"ACX50287.1  SRY-box containing protein 17, partial [Eleutherodact...  <a href=#ACX50287.1>128</a>     2e-30 \n"+
"XP_006624184.1  PREDICTED: transcription factor Sox-8-like [Apis ...  <a href=#XP_006624184.1>123</a>     2e-30 \n"+
"XP_015519572.1  PREDICTED: SOX domain-containing protein dichaete...  <a href=#XP_015519572.1>124</a>     3e-30 \n"+
"XP_012262763.1  PREDICTED: transcription factor SOX-14-like [Atha...  <a href=#XP_012262763.1>125</a>     3e-30 \n"+
"KPI97312.1  Transcription factor SOX-9 [Papilio xuthus]               <a href=#KPI97312.1>123</a>     4e-30 \n"+
"ACF06316.1  Sox9, partial [Oncorhynchus mykiss]                       <a href=#ACF06316.1>119</a>     5e-30 \n"+
"KNC25060.1  hypothetical protein FF38_11817, partial [Lucilia cup...  <a href=#KNC25060.1>132</a>     6e-30 \n"+
"XP_017327721.1  PREDICTED: transcription factor Sox-17-alpha-like...  <a href=#XP_017327721.1>129</a>     7e-30 \n"+
"KPP65607.1  transcription factor Sox-7-like [Scleropages formosus]    <a href=#KPP65607.1>128</a>     7e-30 \n"+
"XP_014211339.1  PREDICTED: transcription factor SOX-9-like [Copid...  <a href=#XP_014211339.1>128</a>     9e-30 \n"+
"XP_006030602.1  PREDICTED: transcription factor SOX-12 [Alligator...  <a href=#XP_006030602.1>123</a>     1e-29 \n"+
"XP_013863771.1  PREDICTED: transcription factor SOX-17 [Austrofun...  <a href=#XP_013863771.1>128</a>     1e-29 \n"+
"XP_007902655.1  PREDICTED: transcription factor Sox-7-like [Callo...  <a href=#XP_007902655.1>127</a>     1e-29 \n"+
"EJW85535.1  hypothetical protein WUBG_03553, partial [Wuchereria ...  <a href=#EJW85535.1>121</a>     1e-29 \n"+
"XP_015781109.1  PREDICTED: putative uncharacterized protein DDB_G...  <a href=#XP_015781109.1>131</a>     2e-29 \n"+
"XP_009091490.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_009091490.1>126</a>     2e-29 \n"+
"XP_006077057.1  PREDICTED: transcription factor SOX-17 [Bubalus b...  <a href=#XP_006077057.1>124</a>     2e-29 \n"+
"XP_017779068.1  PREDICTED: SOX domain-containing protein dichaete...  <a href=#XP_017779068.1>120</a>     2e-29 \n"+
"XP_018404069.1  PREDICTED: transcription factor SOX-8-like, parti...  <a href=#XP_018404069.1>119</a>     2e-29 \n"+
"ACZ25557.1  SRY-box containing protein B2b2, partial [Macrobrachi...  <a href=#ACZ25557.1>119</a>     3e-29 \n"+
"XP_009283373.1  PREDICTED: transcription factor SOX-4 [Aptenodyte...  <a href=#XP_009283373.1>124</a>     3e-29 \n"+
"ABG66955.1  SOX10, partial [Ornithorhynchus anatinus]                 <a href=#ABG66955.1>119</a>     3e-29 \n"+
"BAC26228.1  unnamed protein product [Mus musculus]                    <a href=#BAC26228.1>124</a>     3e-29 \n"+
"XP_005107482.1  PREDICTED: uncharacterized protein LOC101859813 [...  <a href=#XP_005107482.1>130</a>     4e-29 \n"+
"KYO39461.1  hypothetical protein Y1Q_0021104 [Alligator mississip...  <a href=#KYO39461.1>119</a>     4e-29 \n"+
"XP_017931822.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_017931822.1>127</a>     4e-29 \n"+
"XP_013783188.1  PREDICTED: transcription factor Sox-14-like [Limu...  <a href=#XP_013783188.1>123</a>     4e-29 \n"+
"XP_005240020.2  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_005240020.2>124</a>     4e-29 \n"+
"XP_010022474.1  PREDICTED: transcription factor SOX-7-like, parti...  <a href=#XP_010022474.1>118</a>     4e-29 \n"+
"XP_014712045.1  PREDICTED: transcription factor SOX-4 [Equus asinus]  <a href=#XP_014712045.1>120</a>     5e-29 \n"+
"ODN03189.1  Transcription factor Sox-21 [Orchesella cincta]           <a href=#ODN03189.1>122</a>     5e-29 \n"+
"XP_015926892.1  PREDICTED: transcription factor SOX-4-like [Paras...  <a href=#XP_015926892.1>129</a>     6e-29 \n"+
"XP_006220173.2  PREDICTED: SRY-related protein CH31, partial [Vic...  <a href=#XP_006220173.2>117</a>     6e-29 \n"+
"ELT97997.1  hypothetical protein CAPTEDRAFT_162284, partial [Capi...  <a href=#ELT97997.1>122</a>     6e-29 \n"+
"AAW34333.1  SoxF [Petromyzon marinus]                                 <a href=#AAW34333.1>127</a>     6e-29 \n"+
"XP_005108229.1  PREDICTED: transcription factor Sox-14-like [Aply...  <a href=#XP_005108229.1>124</a>     7e-29 \n"+
"XP_012397064.1  PREDICTED: transcription factor SOX-4 [Sarcophilu...  <a href=#XP_012397064.1>124</a>     7e-29 \n"+
"XP_012588378.1  PREDICTED: transcription factor SOX-4 [Condylura ...  <a href=#XP_012588378.1>120</a>     8e-29 \n"+
"AAQ72474.1  Sox4a [Danio rerio]                                       <a href=#AAQ72474.1>125</a>     8e-29 \n"+
"XP_015726536.1  PREDICTED: transcription factor SOX-14 isoform X2...  <a href=#XP_015726536.1>120</a>     8e-29 \n"+
"XP_007883198.1  PREDICTED: transcription factor SOX-18 [Callorhin...  <a href=#XP_007883198.1>125</a>     9e-29 \n"+
"XP_009906066.1  PREDICTED: transcription factor SOX-7 [Picoides p...  <a href=#XP_009906066.1>125</a>     9e-29 \n"+
"KRT84656.1  hypothetical protein AMK59_1879, partial [Oryctes bor...  <a href=#KRT84656.1>118</a>     1e-28 \n"+
"XP_015279104.1  PREDICTED: transcription factor SOX-12 [Gekko jap...  <a href=#XP_015279104.1>123</a>     1e-28 \n"+
"XP_006003042.1  PREDICTED: transcription factor SOX-7 [Latimeria ...  <a href=#XP_006003042.1>124</a>     1e-28 \n"+
"XP_012975545.1  PREDICTED: transcription factor SOX-21 [Mesocrice...  <a href=#XP_012975545.1>119</a>     1e-28 \n"+
"XP_011579667.1  PREDICTED: transcription factor SOX-4 [Aquila chr...  <a href=#XP_011579667.1>123</a>     1e-28 \n"+
"XP_016403489.1  PREDICTED: transcription factor Sox-7-like, parti...  <a href=#XP_016403489.1>119</a>     1e-28 \n"+
"XP_014021031.1  PREDICTED: transcription factor Sox-21-B-like [Sa...  <a href=#XP_014021031.1>121</a>     1e-28 \n"+
"XP_015220505.1  PREDICTED: transcription factor SOX-18 [Lepisoste...  <a href=#XP_015220505.1>125</a>     1e-28 \n"+
"XP_014249991.1  PREDICTED: SOX domain-containing protein dichaete...  <a href=#XP_014249991.1>121</a>     1e-28 \n"+
"XP_010789329.1  PREDICTED: transcription factor Sox-11-A-like [No...  <a href=#XP_010789329.1>123</a>     1e-28 \n"+
"ALC04236.1  sex determining region Y-box 2 [Eisenia fetida]           <a href=#ALC04236.1>124</a>     1e-28 \n"+
"CAY12631.1  SRY-related HMG box B protein [Platynereis dumerilii]     <a href=#CAY12631.1>122</a>     2e-28 \n"+
"Q06831.2  RecName: Full=Transcription factor SOX-4                    <a href=#Q06831.2>125</a>     2e-28 \n"+
"KPM05146.1  hypothetical protein QR98_0036050 [Sarcoptes scabiei]     <a href=#KPM05146.1>126</a>     2e-28 \n"+
"BAE06705.1  transcription factor protein [Ciona intestinalis]         <a href=#BAE06705.1>123</a>     2e-28 \n"+
"XP_016063191.1  PREDICTED: transcription factor SOX-17 [Miniopter...  <a href=#XP_016063191.1>120</a>     2e-28 \n"+
"ETE59996.1  Transcription factor SOX-12, partial [Ophiophagus han...  <a href=#ETE59996.1>123</a>     2e-28 \n"+
"XP_007475557.2  PREDICTED: transcription factor SOX-18 [Monodelph...  <a href=#XP_007475557.2>125</a>     2e-28 \n"+
"XP_004061730.1  PREDICTED: transcription factor SOX-12, partial [...  <a href=#XP_004061730.1>117</a>     2e-28 \n"+
"XP_011483138.1  PREDICTED: transcription factor SOX-4 isoform X1 ...  <a href=#XP_011483138.1>123</a>     2e-28 \n"+
"AAS90948.1  SRY-box 10, partial [Sus scrofa]                          <a href=#AAS90948.1>116</a>     2e-28 \n"+
"KQL60869.1  hypothetical protein AAES_04462 [Amazona aestiva]         <a href=#KQL60869.1>117</a>     2e-28 \n"+
"EAL41657.2  AGAP000922-PA [Anopheles gambiae str. PEST]               <a href=#EAL41657.2>127</a>     3e-28 \n"+
"CRZ22701.1  Bm3958, isoform a [Brugia malayi]                         <a href=#CRZ22701.1>124</a>     3e-28 \n"+
"KPP76091.1  transcription factor Sox-7-like [Scleropages formosus]    <a href=#KPP76091.1>124</a>     3e-28 \n"+
"XP_002161752.2  PREDICTED: transcription factor SOX-18-like [Hydr...  <a href=#XP_002161752.2>124</a>     3e-28 \n"+
"AAI00556.1  Sox14 protein, partial [Mus musculus]                     <a href=#AAI00556.1>124</a>     3e-28 \n"+
"XP_006899239.1  PREDICTED: LOW QUALITY PROTEIN: protein SOX-15 [E...  <a href=#XP_006899239.1>120</a>     3e-28 \n"+
"KTF84828.1  hypothetical protein cypCar_00006806 [Cyprinus carpio]    <a href=#KTF84828.1>119</a>     3e-28 \n"+
"XP_015502573.1  PREDICTED: transcription factor SOX-12 isoform X1...  <a href=#XP_015502573.1>125</a>     4e-28 \n"+
"CDQ97354.1  unnamed protein product [Oncorhynchus mykiss]             <a href=#CDQ97354.1>119</a>     4e-28 \n"+
"EHJ72187.1  Sox21b [Danaus plexippus]                                 <a href=#EHJ72187.1>119</a>     4e-28 \n"+
"XP_013115892.1  PREDICTED: transcription factor Sox-21-A-like [St...  <a href=#XP_013115892.1>121</a>     4e-28 \n"+
"XP_012331945.1  PREDICTED: transcription factor SOX-4 [Aotus nanc...  <a href=#XP_012331945.1>119</a>     4e-28 \n"+
"XP_011379840.1  PREDICTED: transcription factor SOX-4 [Pteropus v...  <a href=#XP_011379840.1>121</a>     4e-28 \n"+
"OCT79104.1  hypothetical protein XELAEV_18030202mg [Xenopus laevis]   <a href=#OCT79104.1>123</a>     4e-28 \n"+
"AAH63054.1  Sox21 protein, partial [Mus musculus]                     <a href=#AAH63054.1>124</a>     4e-28 \n"+
"XP_014294336.1  PREDICTED: transcription factor Sox-7-like [Halyo...  <a href=#XP_014294336.1>124</a>     4e-28 \n"+
"ENN78216.1  hypothetical protein YQE_05368, partial [Dendroctonus...  <a href=#ENN78216.1>121</a>     4e-28 \n"+
"pir||JC4238  HMG-box transcription factor - mouse                     <a href=#JC4238>123</a>     5e-28 \n"+
"EGV98757.1  Transcription factor SOX-14 [Cricetulus griseus]          <a href=#EGV98757.1>115</a>     5e-28 \n"+
"XP_012890132.1  PREDICTED: transcription factor SOX-14 [Dipodomys...  <a href=#XP_012890132.1>120</a>     5e-28 \n"+
"EMP33252.1  Transcription factor SOX-12 [Chelonia mydas]              <a href=#EMP33252.1>122</a>     5e-28 \n"+
"CAY12635.1  SRY-related HMG box C protein [Platynereis dumerilii]     <a href=#CAY12635.1>120</a>     5e-28 \n"+
"KHN80026.1  Transcription factor Sox-2 [Toxocara canis]               <a href=#KHN80026.1>120</a>     5e-28 \n"+
"XP_010955235.1  PREDICTED: transcription factor SOX-11, partial [...  <a href=#XP_010955235.1>115</a>     6e-28 \n"+
"XP_003742894.1  PREDICTED: uncharacterized protein LOC100908412 [...  <a href=#XP_003742894.1>123</a>     6e-28 \n"+
"XP_014281141.1  PREDICTED: transcription factor Sox-14-like [Haly...  <a href=#XP_014281141.1>120</a>     6e-28 \n"+
"XP_004924250.1  PREDICTED: transcription factor Sox-12-like [Bomb...  <a href=#XP_004924250.1>120</a>     6e-28 \n"+
"XP_014420789.1  PREDICTED: transcription factor SOX-11 [Camelus f...  <a href=#XP_014420789.1>116</a>     7e-28 \n"+
"EZA59007.1  Putative transcription factor SOX-14 [Cerapachys biroi]   <a href=#EZA59007.1>122</a>     7e-28 \n"+
"XP_006010839.1  PREDICTED: transcription factor SOX-18 [Latimeria...  <a href=#XP_006010839.1>123</a>     7e-28 \n"+
"XP_007253714.1  PREDICTED: transcription factor SOX-14 [Astyanax ...  <a href=#XP_007253714.1>120</a>     7e-28 \n"+
"XP_005014806.1  PREDICTED: transcription factor SOX-4 [Anas platy...  <a href=#XP_005014806.1>118</a>     7e-28 \n"+
"XP_005228762.1  PREDICTED: transcription factor SOX-1 [Falco pere...  <a href=#XP_005228762.1>116</a>     7e-28 \n"+
"XP_013817477.1  PREDICTED: transcription factor SOX-4 [Apteryx au...  <a href=#XP_013817477.1>122</a>     7e-28 \n"+
"XP_006121900.1  PREDICTED: transcription factor SOX-4 [Pelodiscus...  <a href=#XP_006121900.1>124</a>     7e-28 \n"+
"KFP89102.1  Transcription factor SOX-2, partial [Apaloderma vitta...  <a href=#KFP89102.1>117</a>     7e-28 \n"+
"ESP05361.1  hypothetical protein LOTGIDRAFT_102459, partial [Lott...  <a href=#ESP05361.1>115</a>     7e-28 \n"+
"KYO32952.1  transcription factor SOX-11 [Alligator mississippiensis]  <a href=#KYO32952.1>117</a>     7e-28 \n"+
"XP_003738059.1  PREDICTED: uncharacterized protein LOC100908535 [...  <a href=#XP_003738059.1>120</a>     7e-28 \n"+
"KPJ07110.1  Transcription factor SOX-21 [Papilio machaon]             <a href=#KPJ07110.1>119</a>     7e-28 \n"+
"XP_017326233.1  PREDICTED: transcription factor Sox-21-B-like [Ic...  <a href=#XP_017326233.1>119</a>     7e-28 \n"+
"XP_006010601.1  PREDICTED: transcription factor SOX-4-like [Latim...  <a href=#XP_006010601.1>122</a>     8e-28 \n"+
"EDO32843.1  predicted protein, partial [Nematostella vectensis]       <a href=#EDO32843.1>114</a>     8e-28 \n"+
"ADB45218.1  SOX4 HMG-box protein, partial [Carassius auratus aura...  <a href=#ADB45218.1>115</a>     8e-28 \n"+
"XP_006013083.1  PREDICTED: transcription factor SOX-4 [Latimeria ...  <a href=#XP_006013083.1>122</a>     8e-28 \n"+
"XP_015184037.1  PREDICTED: putative transcription factor SOX-14 [...  <a href=#XP_015184037.1>120</a>     8e-28 \n"+
"XP_016334420.1  PREDICTED: transcription factor SOX-4 [Sinocycloc...  <a href=#XP_016334420.1>122</a>     9e-28 \n"+
"JAS73158.1  hypothetical protein g.59290, partial [Homalodisca li...  <a href=#JAS73158.1>114</a>     9e-28 \n"+
"KDR12611.1  SOX domain-containing protein dichaete [Zootermopsis ...  <a href=#KDR12611.1>120</a>     9e-28 \n"+
"XP_013401063.1  PREDICTED: transcription factor SOX-14-like [Ling...  <a href=#XP_013401063.1>119</a>     9e-28 \n"+
"XP_005235619.1  PREDICTED: transcription factor SOX-21 [Falco per...  <a href=#XP_005235619.1>120</a>     9e-28 \n"+
"EFB22985.1  hypothetical protein PANDA_007191, partial [Ailuropod...  <a href=#EFB22985.1>117</a>     1e-27 \n"+
"ACF33143.1  SoxF [Acropora millepora]                                 <a href=#ACF33143.1>122</a>     1e-27 \n"+
"XP_013775452.1  PREDICTED: transcription factor Sox-11-A-like [Li...  <a href=#XP_013775452.1>121</a>     1e-27 \n"+
"XP_011487508.1  PREDICTED: transcription factor SOX-1 isoform X1 ...  <a href=#XP_011487508.1>121</a>     1e-27 \n"+
"XP_012297088.1  PREDICTED: transcription factor SOX-11 [Aotus nan...  <a href=#XP_012297088.1>118</a>     1e-27 \n"+
"XP_009636194.1  PREDICTED: transcription factor SOX-4 [Egretta ga...  <a href=#XP_009636194.1>122</a>     1e-27 \n"+
"XP_007487941.1  PREDICTED: transcription factor SOX-4 [Monodelphi...  <a href=#XP_007487941.1>124</a>     1e-27 \n"+
"KTG40364.1  hypothetical protein cypCar_00007729 [Cyprinus carpio]    <a href=#KTG40364.1>118</a>     1e-27 \n"+
"ODN05954.1  Transcription factor SOX-2, partial [Orchesella cincta]   <a href=#ODN05954.1>122</a>     1e-27 \n"+
"CAP34601.1  Protein CBR-SOX-2 [Caenorhabditis briggsae]               <a href=#CAP34601.1>120</a>     1e-27 \n"+
"XP_013792539.1  PREDICTED: transcription factor SOX-4-like [Limul...  <a href=#XP_013792539.1>121</a>     1e-27 \n"+
"XP_018018069.1  PREDICTED: transcription factor Sox-2-like [Hyale...  <a href=#XP_018018069.1>124</a>     1e-27 \n"+
"XP_017337977.1  PREDICTED: transcription factor SOX-4-like [Ictal...  <a href=#XP_017337977.1>120</a>     1e-27 \n"+
"XP_004384095.1  PREDICTED: transcription factor SOX-4 [Trichechus...  <a href=#XP_004384095.1>120</a>     1e-27 \n"+
"XP_014043998.1  PREDICTED: transcription factor Sox-1b-like, part...  <a href=#XP_014043998.1>118</a>     1e-27 \n"+
"ACU12327.1  Sox9 isoform 11, partial [Crocodylus palustris]           <a href=#ACU12327.1>112</a>     1e-27 \n"+
"AGL08098.1  SoxB1 [Sepia officinalis]                                 <a href=#AGL08098.1>120</a>     1e-27 \n"+
"XP_015183522.1  PREDICTED: transcription factor SOX-11-like [Poli...  <a href=#XP_015183522.1>124</a>     1e-27 \n"+
"KFM78367.1  Transcription factor SOX-21, partial [Stegodyphus mim...  <a href=#KFM78367.1>120</a>     1e-27 \n"+
"XP_017926527.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_017926527.1>119</a>     1e-27 \n"+
"XP_007902519.1  PREDICTED: transcription factor SOX-11-like [Call...  <a href=#XP_007902519.1>121</a>     1e-27 \n"+
"XP_012366045.1  PREDICTED: transcription factor SOX-7 [Nomascus l...  <a href=#XP_012366045.1>117</a>     1e-27 \n"+
"XP_004594843.1  PREDICTED: protein SOX-15 [Ochotona princeps]         <a href=#XP_004594843.1>118</a>     1e-27 \n"+
"KPP65045.1  hypothetical protein Z043_116559 [Scleropages formosus]   <a href=#KPP65045.1>116</a>     1e-27 \n"+
"JAT34608.1  hypothetical protein g.21868, partial [Graphocephala ...  <a href=#JAT34608.1>116</a>     1e-27 \n"+
"XP_018018080.1  PREDICTED: transcription factor Sox-14-like [Hyal...  <a href=#XP_018018080.1>121</a>     1e-27 \n"+
"XP_007657221.1  PREDICTED: transcription factor SOX-4 [Ornithorhy...  <a href=#XP_007657221.1>119</a>     2e-27 \n"+
"XP_014241837.1  PREDICTED: transcription factor SOX-2-like isofor...  <a href=#XP_014241837.1>123</a>     2e-27 \n"+
"Q66JF1.1  RecName: Full=Transcription factor Sox-11                   <a href=#Q66JF1.1>121</a>     2e-27 \n"+
"XP_013778101.1  PREDICTED: transcription factor Sox-14-like [Limu...  <a href=#XP_013778101.1>120</a>     2e-27 \n"+
"AJA38029.1  sex determining region Y [Monodelphis domestica]          <a href=#AJA38029.1>117</a>     2e-27 \n"+
"KRT85334.1  hypothetical protein AMK59_839 [Oryctes borbonicus]       <a href=#KRT85334.1>120</a>     2e-27 \n"+
"XP_010620987.1  PREDICTED: transcription factor SOX-11 [Fukomys d...  <a href=#XP_010620987.1>118</a>     2e-27 \n"+
"XP_007636191.1  PREDICTED: transcription factor SOX-4-like [Crice...  <a href=#XP_007636191.1>121</a>     2e-27 \n"+
"XP_017306085.1  PREDICTED: transcription factor SOX-4-like [Ictal...  <a href=#XP_017306085.1>121</a>     2e-27 \n"+
"JAS27366.1  hypothetical protein g.8733, partial [Clastoptera ari...  <a href=#JAS27366.1>114</a>     2e-27 \n"+
"XP_011908100.1  PREDICTED: protein SOX-15 isoform X1 [Cercocebus ...  <a href=#XP_011908100.1>119</a>     2e-27 \n"+
"XP_012151116.1  PREDICTED: SOX domain-containing protein dichaete...  <a href=#XP_012151116.1>117</a>     2e-27 \n"+
"XP_009859013.1  PREDICTED: HMG transcription factor SoxB2 isoform...  <a href=#XP_009859013.1>121</a>     2e-27 \n"+
"ACA04750.1  SoxC-like [Amphimedon queenslandica]                      <a href=#ACA04750.1>122</a>     2e-27 \n"+
"XP_017840299.1  PREDICTED: transcription factor SOX-14 [Drosophil...  <a href=#XP_017840299.1>119</a>     2e-27 \n"+
"XP_007523112.1  PREDICTED: transcription factor SOX-12 [Erinaceus...  <a href=#XP_007523112.1>120</a>     2e-27 \n"+
"XP_017312112.1  PREDICTED: transcription factor SOX-7 [Ictalurus ...  <a href=#XP_017312112.1>121</a>     2e-27 \n"+
"XP_007901360.1  PREDICTED: transcription factor SOX-4 [Callorhinc...  <a href=#XP_007901360.1>121</a>     2e-27 \n"+
"AAX43677.1  SRY-box 15, partial [synthetic construct]                 <a href=#AAX43677.1>117</a>     2e-27 \n"+
"EKC24855.1  Transcription factor SOX-2 [Crassostrea gigas]            <a href=#EKC24855.1>120</a>     2e-27 \n"+
"XP_012409093.1  PREDICTED: transcription factor SOX-12 [Sarcophil...  <a href=#XP_012409093.1>120</a>     2e-27 \n"+
"XP_014061703.1  PREDICTED: transcription factor Sox-7-like [Salmo...  <a href=#XP_014061703.1>122</a>     2e-27 \n"+
"XP_018324554.1  PREDICTED: SOX domain-containing protein dichaete...  <a href=#XP_018324554.1>117</a>     2e-27 \n"+
"XP_015607343.1  PREDICTED: transcription factor Sox-21-B-like [Ce...  <a href=#XP_015607343.1>120</a>     2e-27 \n"+
"XP_006005741.1  PREDICTED: transcription factor Sox-19a-like [Lat...  <a href=#XP_006005741.1>119</a>     2e-27 \n"+
"Q90ZH8.1  RecName: Full=Transcription factor Sox-18A; Short=xSox1...  <a href=#Q90ZH8.1>120</a>     2e-27 \n"+
"XP_015522370.1  PREDICTED: transcription factor SOX-3 [Neodiprion...  <a href=#XP_015522370.1>119</a>     2e-27 \n"+
"XP_004605255.2  PREDICTED: protein SOX-15 [Sorex araneus]             <a href=#XP_004605255.2>117</a>     2e-27 \n"+
"XP_015929247.1  PREDICTED: putative transcription factor SOX-14 [...  <a href=#XP_015929247.1>120</a>     3e-27 \n"+
"CAP27551.1  Protein CBR-SOX-3 [Caenorhabditis briggsae]               <a href=#CAP27551.1>117</a>     3e-27 \n"+
"ETE68877.1  Transcription factor SOX-4, partial [Ophiophagus hannah]  <a href=#ETE68877.1>119</a>     3e-27 \n"+
"XP_015687179.1  PREDICTED: transcription factor SOX-4 [Protobothr...  <a href=#XP_015687179.1>122</a>     3e-27 \n"+
"XP_016002151.1  PREDICTED: LOW QUALITY PROTEIN: transcription fac...  <a href=#XP_016002151.1>121</a>     3e-27 \n"+
"XP_014246243.1  PREDICTED: transcription factor SOX-4-like [Cimex...  <a href=#XP_014246243.1>119</a>     3e-27 \n"+
"XP_011292436.1  PREDICTED: putative transcription factor SOX-15 [...  <a href=#XP_011292436.1>124</a>     3e-27 \n"+
"BAO23503.1  HMG transcription factor SoxB2 [Ptychodera flava]         <a href=#BAO23503.1>117</a>     3e-27 \n"+
"XP_015682094.1  PREDICTED: transcription factor SOX-21 [Protoboth...  <a href=#XP_015682094.1>119</a>     3e-27 \n"+
"XP_017334470.1  PREDICTED: transcription factor SOX-2 [Ictalurus ...  <a href=#XP_017334470.1>120</a>     3e-27 \n"+
"XP_011331348.1  PREDICTED: transcription factor SOX-11-like isofo...  <a href=#XP_011331348.1>122</a>     3e-27 \n"+
"EFA04579.1  Sox21a [Tribolium castaneum]                              <a href=#EFA04579.1>117</a>     3e-27 \n"+
"XP_009564044.1  PREDICTED: transcription factor SOX-11 [Cuculus c...  <a href=#XP_009564044.1>117</a>     3e-27 \n"+
"ELK11050.1  Transcription factor SOX-21 [Pteropus alecto]             <a href=#ELK11050.1>124</a>     3e-27 \n"+
"JAT28737.1  hypothetical protein g.21869, partial [Graphocephala ...  <a href=#JAT28737.1>116</a>     3e-27 \n"+
"XP_013201259.1  PREDICTED: transcription factor SOX-21-like [Amye...  <a href=#XP_013201259.1>120</a>     3e-27 \n"+
"KOF62861.1  hypothetical protein OCBIM_22021495mg [Octopus bimacu...  <a href=#KOF62861.1>117</a>     3e-27 \n"+
"XP_013776585.1  PREDICTED: uncharacterized protein LOC106461314 [...  <a href=#XP_013776585.1>122</a>     3e-27 \n"+
"EEN65626.1  hypothetical protein BRAFLDRAFT_125030 [Branchiostoma...  <a href=#EEN65626.1>124</a>     3e-27 \n"+
"EFA04354.2  SOX domain-containing protein dichaete-like Protein [...  <a href=#EFA04354.2>116</a>     3e-27 \n"+
"KTG36172.1  hypothetical protein cypCar_00011805 [Cyprinus carpio]    <a href=#KTG36172.1>118</a>     3e-27 \n"+
"XP_003220734.1  PREDICTED: transcription factor SOX-18 [Anolis ca...  <a href=#XP_003220734.1>122</a>     3e-27 \n"+
"Q7SZS1.1  RecName: Full=Transcription factor Sox-21-A; AltName: F...  <a href=#Q7SZS1.1>117</a>     3e-27 \n"+
"JAN75948.1  Transcription factor Sox-7 [Daphnia magna]                <a href=#JAN75948.1>123</a>     4e-27 \n"+
"ESP04930.1  hypothetical protein LOTGIDRAFT_184905, partial [Lott...  <a href=#ESP04930.1>119</a>     4e-27 \n"+
"EKC30339.1  Putative transcription factor SOX-14 [Crassostrea gigas]  <a href=#EKC30339.1>120</a>     4e-27 \n"+
"XP_010789005.1  PREDICTED: transcription factor SOX-7 [Notothenia...  <a href=#XP_010789005.1>120</a>     4e-27 \n"+
"KFB47267.1  sex-determining region y protein, sry [Anopheles sine...  <a href=#KFB47267.1>116</a>     4e-27 \n"+
"XP_014671379.1  PREDICTED: transcription factor Sox-3-A-like [Pri...  <a href=#XP_014671379.1>120</a>     4e-27 \n"+
"XP_012409532.1  PREDICTED: transcription factor SOX-18 [Sarcophil...  <a href=#XP_012409532.1>120</a>     4e-27 \n"+
"XP_006745983.1  PREDICTED: transcription factor COE3 [Leptonychot...  <a href=#XP_006745983.1>123</a>     4e-27 \n"+
"</PRE>\n"+
"\n"+
"<PRE>\n"+
">BAD90382.1<a name=BAD90382></a> mKIAA4243 protein, partial [Mus musculus]  \n"+
"Length=565\n"+
"\n"+
" Score = 998 bits (2581),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 494/509 (97%), Positives = 497/509 (98%), Gaps = 2/509 (0%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL\n"+
"Sbjct  59   MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  118\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  119  KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  178\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  179  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  238\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTT  240\n"+
"            SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTT\n"+
"Sbjct  239  SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTT  298\n"+
"\n"+
"Query  241  PKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP  300\n"+
"            PKTDVQ GK DLKREGRPL EGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP\n"+
"Sbjct  299  PKTDVQAGKVDLKREGRPLAEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP  358\n"+
"\n"+
"Query  301  NGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPP  360\n"+
"            NGHPGVPATHGQVTYTGSYGISSTA TPA+AGHVWMSKQQAPPPPPQQPPQAP APQAPP\n"+
"Sbjct  359  NGHPGVPATHGQVTYTGSYGISSTAPTPATAGHVWMSKQQAPPPPPQQPPQAPQAPQAPP  418\n"+
"\n"+
"Query  361  QPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAY  420\n"+
"            Q Q APPQQP A PQQ QAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQI+Y\n"+
"Sbjct  419  Q-QQAPPQQPQA-PQQQQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQISY  476\n"+
"\n"+
"Query  421  SPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPI  480\n"+
"            SPFNLPHYSPSYPPITRSQYDY DHQNS SYYSHAAGQG+GLYSTFTYMNPAQRPMYTPI\n"+
"Sbjct  477  SPFNLPHYSPSYPPITRSQYDYADHQNSGSYYSHAAGQGSGLYSTFTYMNPAQRPMYTPI  536\n"+
"\n"+
"Query  481  ADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            ADTSGVPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  537  ADTSGVPSIPQTHSPQHWEQPVYTQLTRP  565\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017519930.1<a name=XP_017519930></a> PREDICTED: transcription factor SOX-9, partial [Manis javanica] \n"+
" \n"+
"Length=355\n"+
"\n"+
" Score = 713 bits (1840),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 348/356 (98%), Positives = 348/356 (98%), Gaps = 1/356 (0%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPC SGSGSD ENTRPQENTFPKGEPDL\n"+
"Sbjct  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCASGSGSDAENTRPQENTFPKGEPDL  60\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTT  240\n"+
"            SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTT\n"+
"Sbjct  181  SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTT  240\n"+
"\n"+
"Query  241  PKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP  300\n"+
"            PKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP\n"+
"Sbjct  241  PKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP  300\n"+
"\n"+
"Query  301  NGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAP  356\n"+
"            NGHPGVPATHG VTYTGSYGISSTAAT   AGHVWMSKQQA PPPPQQPPQAP AP\n"+
"Sbjct  301  NGHPGVPATHGPVTYTGSYGISSTAATQGGAGHVWMSKQQA-PPPPQQPPQAPQAP  355\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014902658.1<a name=XP_014902658></a> PREDICTED: transcription factor SOX-9 [Poecilia latipinna]  \n"+
"Length=482\n"+
"\n"+
" Score = 687 bits (1773),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 381/522 (73%), Positives = 415/522 (80%), Gaps = 53/522 (10%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDP++KMT+EQEK  S APSP+MSEDSAGSPCPSGSGSDTENTRP +N   +G PD \n"+
"Sbjct  1    MNLLDPYLKMTEEQEKCHSDAPSPSMSEDSAGSPCPSGSGSDTENTRPSDNHLLRG-PDY  59\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            KKE EE+KFPVCIR+AVSQVLKGYDWTLVPMPVRVNGSSK+KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  60   KKEGEEEKFPVCIRDAVSQVLKGYDWTLVPMPVRVNGSSKSKPHVKRPMNAFMVWAQAAR  119\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLLNE EKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  120  RKLADQYPHLHNAELSKTLGKLWRLLNEVEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  179\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPPTPPT  239\n"+
"            SVKNGQ E+E+  EQTHISPNAIFKAL QADSP SS  M EVHSPGEHSGQSQGPPTPPT\n"+
"Sbjct  180  SVKNGQNESEDG-EQTHISPNAIFKALQQADSPASS--MGEVHSPGEHSGQSQGPPTPPT  236\n"+
"\n"+
"Query  240  TPKTDVQPGKADLKREGRPLPEG-GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYL  298\n"+
"            TPKTD+   KADLKREGRP+ EG  RQ  IDF  VDIGELSSDVISNI +FDV+EFDQYL\n"+
"Sbjct  237  TPKTDLPSSKADLKREGRPIQEGSSRQLNIDFGAVDIGELSSDVISNIGSFDVDEFDQYL  296\n"+
"\n"+
"Query  299  PPNGHPGVPATHGQVTYTGSYGISSTAATPASAG---HVWMSKQQAPPPPPQQPPQAPPA  355\n"+
"            PP+ H GV     Q  YTGSYGI STA+    AG   H WMSKQQ               \n"+
"Sbjct  297  PPHSHAGVVGA-AQAGYTGSYGI-STASVGQGAGVGAHAWMSKQQQ--------------  340\n"+
"\n"+
"Query  356  PQAPPQPQAAPPQQPAAPPQQPQAHTLTTL-----SSEPGQSQRTHIKTEQLSPSHYSEQ  410\n"+
"                               QQ Q HTLTTL       + GQ + T IKTEQLSPSHYS+Q\n"+
"Sbjct  341  -------------------QQQQQHTLTTLGGAGEQGQQGQQRTTQIKTEQLSPSHYSDQ  381\n"+
"\n"+
"Query  411  QQHSPQQIAYSPFNLPHYSP-SYPPITRSQYDYTDHQNSS-SYYSHAAGQGTGLYSTFTY  468\n"+
"            Q  SPQ I Y  FNL HYSP SYP ITR+QYDY++HQ+S+ SYYSHAAGQG+ LYSTF+Y\n"+
"Sbjct  382  QG-SPQHITYGSFNLQHYSPSSYPSITRAQYDYSEHQSSANSYYSHAAGQGSSLYSTFSY  440\n"+
"\n"+
"Query  469  MNPAQRPMYTPIADTSGVPSIPQTHSPQHWE-QPVYTQLTRP  509\n"+
"            M+P+QRPMYTPIAD++GVPS+PQTHSPQHWE QP+YTQL+RP\n"+
"Sbjct  441  MSPSQRPMYTPIADSTGVPSVPQTHSPQHWEQQPIYTQLSRP  482\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007240551.1<a name=XP_007240551></a> PREDICTED: transcription factor Sox-9-A-like [Astyanax mexicanus] \n"+
" \n"+
"Length=492\n"+
"\n"+
" Score = 661 bits (1706),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 358/526 (68%), Positives = 397/526 (75%), Gaps = 51/526 (10%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDPF+KMTDEQ+KGLS APSP++SEDSAGSPCPS SGSD +    +         D \n"+
"Sbjct  1    MNLLDPFLKMTDEQDKGLSAAPSPSLSEDSAGSPCPSASGSDPDRAAAESRLH-----DF  55\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            KK+  +DKFPVCIREAV+QVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  56   KKDEVDDKFPVCIREAVTQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  115\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLLN++EKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  116  RKLADQYPHLHNAELSKTLGKLWRLLNDAEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  175\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPPTPPT  239\n"+
"            SVKNG  E E+ ++  H+SPNAIFKAL QADSP SS  M EVHSP E  GQSQGPPTPPT\n"+
"Sbjct  176  SVKNGSGEGEDGSDHAHVSPNAIFKALQQADSPASS--MGEVHSPSEQGGQSQGPPTPPT  233\n"+
"\n"+
"Query  240  TPKTDVQPGKADLKREGRPLPE----GGRQPPIDFRDVDIGELSSDVISNIETFDVNEFD  295\n"+
"            TPK D QPGK DLKREGRPL E    GGRQ  IDFRDVDIGELSSDVIS++E+FDV EFD\n"+
"Sbjct  234  TPKIDTQPGKVDLKREGRPLQEGVSSGGRQLNIDFRDVDIGELSSDVISHMESFDVAEFD  293\n"+
"\n"+
"Query  296  QYLPPNGHPGVPATHGQVTYTGSYGISS-TAATPASAGHVWMSKQQAPPPPPQQPPQAPP  354\n"+
"            QYLPPNGHPG         Y G Y ++       A+AG VWMSK Q+             \n"+
"Sbjct  294  QYLPPNGHPG-------AAYVGGYSLAGPGTVGQAAAGGVWMSKTQS------------G  334\n"+
"\n"+
"Query  355  APQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQR-----THIKTEQLSPSHYSE  409\n"+
"             PQ  PQP     QQ          H+LT L +  G  Q      THIKTEQLSPSHYSE\n"+
"Sbjct  335  NPQGGPQPSNQQQQQQQ-------QHSLTQLGTGNGGDQGQQRTPTHIKTEQLSPSHYSE  387\n"+
"\n"+
"Query  410  QQQHSPQQIAYSPFNLPHYSP-SYPPITRSQYDYTDHQN---SSSYYSHAAGQGTGLYST  465\n"+
"            QQ  SPQ + Y  FNL HY+  S+P I+R+QYDY D Q    ++SYYSHAAGQG+GLYST\n"+
"Sbjct  388  QQG-SPQHVTYGSFNLQHYTASSFPSISRAQYDYGDQQGAATAASYYSHAAGQGSGLYST  446\n"+
"\n"+
"Query  466  FTYMNPAQRPMYTPIADTSGVPSIPQT-HSPQHWE-QPVYTQLTRP  509\n"+
"            F+Y++P+QRPMYTPI D++GVPSIP   HSPQHW+ QPVYTQLTRP\n"+
"Sbjct  447  FSYVSPSQRPMYTPITDSAGVPSIPSAGHSPQHWDQQPVYTQLTRP  492\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010974287.1<a name=XP_010974287></a> PREDICTED: transcription factor SOX-9 [Camelus dromedarius]  \n"+
"\n"+
"Length=426\n"+
"\n"+
" Score = 659 bits (1700),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 326/328 (99%), Positives = 327/328 (99%), Gaps = 0/328 (0%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL\n"+
"Sbjct  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTT  240\n"+
"            SVKNGQAEAEEA+EQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTT\n"+
"Sbjct  181  SVKNGQAEAEEASEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTT  240\n"+
"\n"+
"Query  241  PKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP  300\n"+
"            PKTDVQPGKADLKREGRPL EGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP\n"+
"Sbjct  241  PKTDVQPGKADLKREGRPLSEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP  300\n"+
"\n"+
"Query  301  NGHPGVPATHGQVTYTGSYGISSTAATP  328\n"+
"            NGHPGVPATHGQVTYTGSYGISSTAATP\n"+
"Sbjct  301  NGHPGVPATHGQVTYTGSYGISSTAATP  328\n"+
"\n"+
"\n"+
" Score = 203 bits (516),  Expect = 4e-57, Method: Compositional matrix adjust.\n"+
" Identities = 95/98 (97%), Positives = 97/98 (99%), Gaps = 0/98 (0%)\n"+
"\n"+
"Query  412  QHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNP  471\n"+
"            QHSPQQIAYSPF+LPHYSPSYPPITRSQYDYTDHQNS SYYSHAAGQG+GLYSTFTYMNP\n"+
"Sbjct  329  QHSPQQIAYSPFSLPHYSPSYPPITRSQYDYTDHQNSGSYYSHAAGQGSGLYSTFTYMNP  388\n"+
"\n"+
"Query  472  AQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            AQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  389  AQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  426\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014953896.1<a name=XP_014953896></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-9 isoform \n"+
"X1 [Ovis aries]  \n"+
"Length=574\n"+
"\n"+
" Score = 619 bits (1597),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 339/480 (71%), Positives = 363/480 (76%), Gaps = 19/480 (4%)\n"+
"\n"+
"Query  48   PQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKR  107\n"+
"            P  NTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKR\n"+
"Sbjct  96   PGSNTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKR  155\n"+
"\n"+
"Query  108  PMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKK  167\n"+
"            PMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKK\n"+
"Sbjct  156  PMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKK  215\n"+
"\n"+
"Query  168  DHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEH  227\n"+
"            DHPDYKYQPRRRKSVKNGQAEAEEA EQTHISPNAIFKALQADSPHSSSGMSEVHSPGEH\n"+
"Sbjct  216  DHPDYKYQPRRRKSVKNGQAEAEEAPEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEH  275\n"+
"\n"+
"Query  228  SG-QSQGPPTPPTTPKTDVQP-GKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISN  285\n"+
"            SG Q QGP   PTTP+TDVQ  GKADLKREG P   G   PP   RDV IGE ++ + SN\n"+
"Sbjct  276  SGEQLQGPQDAPTTPRTDVQARGKADLKREGAPCKRGAGSPPSTLRDVTIGEAAATINSN  335\n"+
"\n"+
"Query  286  IETFD--VNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPP  343\n"+
"            +ET    +  FD  +PPNGHPGVPATHGQVT   +Y        P  AGHVWMS  +   \n"+
"Sbjct  336  METASERLTRFDHTMPPNGHPGVPATHGQVTLRAAYAXDKHGGQPGGAGHVWMSSSRPAA  395\n"+
"\n"+
"Query  344  PPPQQPPQAPPAPQAPPQP------------QAAPPQQPAAPPQQPQAHTLTTLSSEPGQ  391\n"+
"            P PQ   + PP   APPQ             ++APPQ+P               S  P Q\n"+
"Sbjct  396  PAPQAARRPPPPQPAPPQAPPPTGPAARRPRRSAPPQKPPQTAAAAPPPRRPQASRPPAQ  455\n"+
"\n"+
"Query  392  SQRTHIKTEQLSPSHYSEQ-QQHSPQQIAYSPFNLPHYS-PSYPPITRSQYDYTDHQNSS  449\n"+
"            +  T  KTEQ      +E  QQH     +  P  LPH + PSYPPITR+ YDY+D QNS \n"+
"Sbjct  456  ANCTS-KTEQAEARATTESTQQHLAAGRSPKPLRLPHXNGPSYPPITRAXYDYSDPQNSG  514\n"+
"\n"+
"Query  450  SYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            +  +HAAGQG+GLYSTF+YM+PAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  515  ATTAHAAGQGSGLYSTFSYMSPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  574\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011857245.1<a name=XP_011857245></a> PREDICTED: transcription factor SOX-9 [Mandrillus leucophaeus] \n"+
" \n"+
"Length=428\n"+
"\n"+
" Score = 605 bits (1560),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 317/367 (86%), Positives = 317/367 (86%), Gaps = 49/367 (13%)\n"+
"\n"+
"Query  143  WRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNA  202\n"+
"             RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNA\n"+
"Sbjct  111  LRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNA  170\n"+
"\n"+
"Query  203  IFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEG  262\n"+
"            IFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEG\n"+
"Sbjct  171  IFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEG  230\n"+
"\n"+
"Query  263  GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGIS  322\n"+
"            GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGIS\n"+
"Sbjct  231  GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGIS  290\n"+
"\n"+
"Query  323  STAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTL  382\n"+
"            STA                                                 QQPQAHTL\n"+
"Sbjct  291  STA-------------------------------------------------QQPQAHTL  301\n"+
"\n"+
"Query  383  TTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDY  442\n"+
"            TTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDY\n"+
"Sbjct  302  TTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDY  361\n"+
"\n"+
"Query  443  TDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPV  502\n"+
"            TDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPV\n"+
"Sbjct  362  TDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPV  421\n"+
"\n"+
"Query  503  YTQLTRP  509\n"+
"            YTQLTRP\n"+
"Sbjct  422  YTQLTRP  428\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010719808.1<a name=XP_010719808></a> PREDICTED: transcription factor SOX-9 [Meleagris gallopavo]  \n"+
"\n"+
"Length=451\n"+
"\n"+
" Score = 591 bits (1524),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 299/322 (93%), Positives = 310/322 (96%), Gaps = 3/322 (1%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDPFMKMT+EQ+K +S APSPTMS+DSAGSPCPSGSGSDTENTRPQENTFPKG+PDL\n"+
"Sbjct  1    MNLLDPFMKMTEEQDKCISDAPSPTMSDDSAGSPCPSGSGSDTENTRPQENTFPKGDPDL  60\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            KKES+EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  61   KKESDEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTT  240\n"+
"            SVKNGQ+E EE +EQTHISPNAIFKALQADSP SSS +SEVHSPGEHSGQSQGPPTPPTT\n"+
"Sbjct  181  SVKNGQSEQEEGSEQTHISPNAIFKALQADSPQSSSSISEVHSPGEHSGQSQGPPTPPTT  240\n"+
"\n"+
"Query  241  PKTDV-QPGKADLKREGRPLPEGGRQPP-IDFRDVDIGELSSDVISNIETFDVNEFDQYL  298\n"+
"            PKTD  QPGK DLKREGRPL EGGRQPP IDFRDVDIGELSSDVISNIETFDVNEFDQYL\n"+
"Sbjct  241  PKTDAQQPGKQDLKREGRPLAEGGRQPPHIDFRDVDIGELSSDVISNIETFDVNEFDQYL  300\n"+
"\n"+
"Query  299  PPNGHPGVPATHGQV-TYTGSY  319\n"+
"            PPNGHPGVPATHGQV TY+G+Y\n"+
"Sbjct  301  PPNGHPGVPATHGQVTTYSGTY  322\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_001098555.1<a name=NP_001098555></a> transcription factor SOX9 [Oryzias latipes]\n"+
" BAC06353.1<a name=BAC06353></a> SOX9 longer form [Oryzias latipes]  \n"+
"Length=565\n"+
"\n"+
" Score = 589 bits (1519),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 358/527 (68%), Positives = 389/527 (74%), Gaps = 58/527 (11%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGS-DTENTRPQENTFPKGEPD  59\n"+
"            MNLLDP++KMT+EQ+K LS APSP+MSEDSAGSP        DTENTRP+EN   + +  \n"+
"Sbjct  79   MNLLDPYLKMTEEQDKCLSDAPSPSMSEDSAGSPASPSGSGSDTENTRPRENGLMRADGA  138\n"+
"\n"+
"Query  60   LK--KESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQ  117\n"+
"            L   K+ E+DKFP CIREAVSQVLKGYDWTLVPMPVRVNGS+KNKPHVKRPMNAFMVWAQ\n"+
"Sbjct  139  LSDFKKDEDDKFPACIREAVSQVLKGYDWTLVPMPVRVNGSTKNKPHVKRPMNAFMVWAQ  198\n"+
"\n"+
"Query  118  AARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPR  177\n"+
"            AARRKLADQYPHLHNAELSKTLGKLWRLLNE EKRPFVEEAERLRVQHKKDHPDYKYQPR\n"+
"Sbjct  199  AARRKLADQYPHLHNAELSKTLGKLWRLLNEGEKRPFVEEAERLRVQHKKDHPDYKYQPR  258\n"+
"\n"+
"Query  178  RRKSVKNGQAEAEEATEQTHISPNAIFKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPPT  236\n"+
"            RRKSVK+G +EAE+  E  HIS NAIFKAL QADSP SS  M EVHSP EHSG SQ PPT\n"+
"Sbjct  259  RRKSVKSGGSEAEDGGE--HISTNAIFKALQQADSPASS--MGEVHSPAEHSG-SQAPPT  313\n"+
"\n"+
"Query  237  PPTTPKTDVQPGKADLKREG--RPLPEG--GRQPPIDFRDVDIGELSSDVISNIETFDVN  292\n"+
"            PPTTPKTD    K DLKREG  RPLP+G  GRQ  IDFRDVDIGELSSDVIS+IETFDVN\n"+
"Sbjct  314  PPTTPKTDCS-AKMDLKREGGLRPLPDGAPGRQLNIDFRDVDIGELSSDVISHIETFDVN  372\n"+
"\n"+
"Query  293  EFDQYLPPNGHPG-VPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQ  351\n"+
"            EFDQYLPPNGHPG  P +   V+Y+G+Y IS                          PP \n"+
"Sbjct  373  EFDQYLPPNGHPGAAPGSTAPVSYSGNYSISGA------------------------PPL  408\n"+
"\n"+
"Query  352  APPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQS---QRTHIKTEQLSPSHYS  408\n"+
"            +P A   P     A  QQ        Q H+LT L +  G     +RT IKTEQLSPSHYS\n"+
"Sbjct  409  SPQAGGGPAWMAKAHSQQ--------QQHSLTPLGTSGGSEAALRRTQIKTEQLSPSHYS  460\n"+
"\n"+
"Query  409  EQQQHSPQQIAYSPFNLPH---YSPSYPPITRS-QYDYTDHQNSSSYYSHAAGQGTGLYS  464\n"+
"            E QQ SPQ   YSPFNL H    S SYPPI+R+ QYDY D Q    Y    AGQG+GLYS\n"+
"Sbjct  461  E-QQGSPQNAPYSPFNLQHYSPPSSSYPPISRAQQYDYPDPQGGGFYSPAGAGQGSGLYS  519\n"+
"\n"+
"Query  465  TFTYM-NPAQRPMYTPIADTSGVPSIPQTHSPQHWEQ-PVYTQLTRP  509\n"+
"            TF+YM +P+QRPMYTPIAD +GVPSIPQ  SPQHWEQ PVYTQLTRP\n"+
"Sbjct  520  TFSYMSSPSQRPMYTPIADNAGVPSIPQG-SPQHWEQAPVYTQLTRP  565\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KTG34845.1<a name=KTG34845></a> hypothetical protein cypCar_00020995 [Cyprinus carpio]  \n"+
"Length=457\n"+
"\n"+
" Score = 575 bits (1482),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 332/491 (68%), Positives = 358/491 (73%), Gaps = 75/491 (15%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDP++KMT+EQEK LS APSP+MSEDSAGSP      SDTENTR        GE   \n"+
"Sbjct  1    MNLLDPYLKMTEEQEKCLSDAPSPSMSEDSAGSPGSGSG-SDTENTRLAAPDATLGE---  56\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"             K+ EEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  57   FKKDEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  116\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLLNE EKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  117  RKLADQYPHLHNAELSKTLGKLWRLLNEGEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  176\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPPTPPT  239\n"+
"            SVKNGQ+E+E+ +EQTHISPNAIFKAL QADSP SS  M EVHSP EHSGQSQGPPTPPT\n"+
"Sbjct  177  SVKNGQSESEDGSEQTHISPNAIFKALQQADSPASS--MGEVHSPSEHSGQSQGPPTPPT  234\n"+
"\n"+
"Query  240  TPKTDVQPGKADLKREGRPLPEG-GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYL  298\n"+
"            TPKTD QPGK DLKRE RPL E  GR   IDFRDVDIGELSSDV   IETFDVNEFDQYL\n"+
"Sbjct  235  TPKTDAQPGKVDLKREARPLQESTGRPLNIDFRDVDIGELSSDV---IETFDVNEFDQYL  291\n"+
"\n"+
"Query  299  PPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQA  358\n"+
"            PPNGH                      AT AS    WM K Q   PP  Q          \n"+
"Sbjct  292  PPNGH----------------------ATNASYYATWMGKPQNGSPPNAQ----------  319\n"+
"\n"+
"Query  359  PPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQI  418\n"+
"                                      L+ E  Q + THIKTEQLSPSHY++Q   SPQQ \n"+
"Sbjct  320  --------------------------LTGEQEQPRTTHIKTEQLSPSHYNDQG--SPQQP  351\n"+
"\n"+
"Query  419  AYSPFN---LPHYSPSYPPITRSQYDYTDHQ-NSSSYYSHAAGQGTGLYSTFTYMNPAQR  474\n"+
"            +Y  FN   L HYS S+P ITR+QYDY+DHQ  ++SYY+HA GQ +GLYSTF+YM+ +QR\n"+
"Sbjct  352  SYGSFNVQHLQHYSTSFPSITRAQYDYSDHQGGANSYYTHAGGQSSGLYSTFSYMSSSQR  411\n"+
"\n"+
"Query  475  PMYTPIADTSG  485\n"+
"            PMYTPIAD++G\n"+
"Sbjct  412  PMYTPIADSAG  422\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AFA46805.1<a name=AFA46805></a> Sox9 [Gadus morhua]  \n"+
"Length=505\n"+
"\n"+
" Score = 574 bits (1480),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 354/581 (61%), Positives = 379/581 (65%), Gaps = 148/581 (25%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEP--  58\n"+
"            MNLLDPF+KMT+EQEK LS  PSP+MSEDS GSPCPS S SDTENTRP EN F + +   \n"+
"Sbjct  1    MNLLDPFLKMTEEQEKCLSDVPSPSMSEDSTGSPCPSSSSSDTENTRPSENGFLRADGVT  60\n"+
"\n"+
"Query  59   --DLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWA  116\n"+
"              D KK+ EEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWA\n"+
"Sbjct  61   IGDFKKD-EEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWA  119\n"+
"\n"+
"Query  117  QAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQP  176\n"+
"            QAARRKLADQYPHLHNAELSKTLGKLWRLLNE EKRPFVEEAERLRVQHKKDHPDYKYQP\n"+
"Sbjct  120  QAARRKLADQYPHLHNAELSKTLGKLWRLLNEGEKRPFVEEAERLRVQHKKDHPDYKYQP  179\n"+
"\n"+
"Query  177  RRRKSVKNGQAEAEEATEQTHISPNAIFKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPP  235\n"+
"            RRRKSVKNGQ E+E+  EQTHI+PNAIFKAL QADSP SS  M +VHSPGEHSG SQGPP\n"+
"Sbjct  180  RRRKSVKNGQGESEDGGEQTHITPNAIFKALQQADSPASS--MGDVHSPGEHSG-SQGPP  236\n"+
"\n"+
"Query  236  TPPTTPKTDVQPGKADLKREG--RPLPEG---------GRQPPIDFRDVDIGELSSDVIS  284\n"+
"            TPPTTPKTDV  GK DLKRE   RP  +G         GRQ  IDFRDVDIGELSSDVIS\n"+
"Sbjct  237  TPPTTPKTDVISGKMDLKREAGVRPAQDGPSPSAAAAVGRQLNIDFRDVDIGELSSDVIS  296\n"+
"\n"+
"Query  285  NIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPP  344\n"+
"            +IETFDVNEFDQYLPPNGHPG              G    A  P++    WM K Q+   \n"+
"Sbjct  297  HIETFDVNEFDQYLPPNGHPG--------------GAGVAAFCPSA----WMGKGQSL--  336\n"+
"\n"+
"Query  345  PPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSP  404\n"+
"                                                          Q QRTHIKTEQLSP\n"+
"Sbjct  337  ----------------------------------------------QQQRTHIKTEQLSP  350\n"+
"\n"+
"Query  405  SHYSEQ------------------QQHSPQQIAYSPFNLPHYSPS---------------  431\n"+
"             HYSEQ                  QQ SPQ ++Y  FNL HYS S               \n"+
"Sbjct  351  GHYSEQLSPGHYSEQQQQQQQQQQQQSSPQHLSYGSFNLQHYSSSSGGSVNAPALSSASV  410\n"+
"\n"+
"Query  432  --------YPPITRSQYDYT-DHQNSS----SYYSHAAGQGTGLYSTFTYMNP-------  471\n"+
"                    YP  TR+QYDY+ D Q       SYY      G G++S F YM P       \n"+
"Sbjct  411  SAAAASSVYPTTTRTQYDYSVDPQQGGGAGPSYY------GQGMFSAFGYMLPGSPPAGQ  464\n"+
"\n"+
"Query  472  AQRPMYTPIADTSGVPSIPQ-THSPQHWEQ--PVYTQLTRP  509\n"+
"            +QRPMYTPIADT+GVPS+PQ +HSPQHWE   PVYTQLTRP\n"+
"Sbjct  465  SQRPMYTPIADTTGVPSVPQSSHSPQHWEHQTPVYTQLTRP  505\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012673302.1<a name=XP_012673302></a> PREDICTED: transcription factor Sox-9-A-like [Clupea harengus] \n"+
" \n"+
"Length=512\n"+
"\n"+
" Score = 559 bits (1440),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 334/547 (61%), Positives = 374/547 (68%), Gaps = 73/547 (13%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDP++KM D+QEK LSGAPSP+MSEDS GSPCPSGS SDTENTRP EN+   G    \n"+
"Sbjct  1    MNLLDPYLKMADDQEKCLSGAPSPSMSEDSGGSPCPSGSSSDTENTRPAENSL-LGPDGC  59\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            KK+ ++ KFPVCIR+AVSQVLKGYDWTLVPMPVRVNGS KNKPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  60   KKDEDDGKFPVCIRDAVSQVLKGYDWTLVPMPVRVNGSGKNKPHVKRPMNAFMVWAQAAR  119\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLLN+ EKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  120  RKLADQYPHLHNAELSKTLGKLWRLLNDVEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  179\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPPTPPT  239\n"+
"            SVKNGQ+E E+A EQTHIS NAIFKAL QADSP SS G  +V SPGE SG+   PP   +\n"+
"Sbjct  180  SVKNGQSEPEDAMEQTHISSNAIFKALQQADSPASSLG--DVQSPGELSGK---PPRKHS  234\n"+
"\n"+
"Query  240  TPKTDV-------QPGKADLKREGRPLPE------GGRQPPIDFRDVDIGELSSDVISNI  286\n"+
"              +T                KREGRPL +       GRQ  IDFRDVDIGELSS+VIS+I\n"+
"Sbjct  235  MKRTSASRXXXXXXXXXXXXKREGRPLVDRPLLDSSGRQLNIDFRDVDIGELSSEVISHI  294\n"+
"\n"+
"Query  287  ETFDVNEFDQYLPPNGHPG-------VPATHGQVTYTGSYGISSTAATPASAGHVWMSKQ  339\n"+
"            ETFDV+EFDQYLPPNGHPG         +     TY    G S+   T A+AG  W+SK \n"+
"Sbjct  295  ETFDVHEFDQYLPPNGHPGGAMSTAASVSAAYSATYGMGGGGSTVGPTAAAAG-AWLSKS  353\n"+
"\n"+
"Query  340  QAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRT----  395\n"+
"            Q P P                              Q  Q H+LT L    G  Q      \n"+
"Sbjct  354  QTPSP----------------------------GQQSQQGHSLTPLGGGGGGEQGQTQTQ  385\n"+
"\n"+
"Query  396  -----HIKTEQLSPSHYSE---QQQHSPQQIAYSPFNLPHYS--PSYPPITRSQYDYTDH  445\n"+
"                 HIKTEQLSPSHYSE   Q    PQ  AY  F++ H+S  PSY   +R+QY++   \n"+
"Sbjct  386  SRPPPHIKTEQLSPSHYSEPPPQGSSPPQHAAYGSFSMQHFSPPPSYTAASRAQYEFDHQ  445\n"+
"\n"+
"Query  446  QNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTH--SPQHWE-QPV  502\n"+
"              +S+YYSHA+     LYSTF+YM+P  RPMYTPIAD +GV S+PQT+  SPQHWE QPV\n"+
"Sbjct  446  GGASAYYSHASAPSPALYSTFSYMSPTHRPMYTPIADNAGVASVPQTNHSSPQHWEQQPV  505\n"+
"\n"+
"Query  503  YTQLTRP  509\n"+
"            YTQLTRP\n"+
"Sbjct  506  YTQLTRP  512\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ETE65376.1<a name=ETE65376></a> Transcription factor SOX-9, partial [Ophiophagus hannah]  \n"+
"Length=374\n"+
"\n"+
" Score = 542 bits (1397),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 304/370 (82%), Positives = 313/370 (85%), Gaps = 19/370 (5%)\n"+
"\n"+
"Query  145  LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIF  204\n"+
"            LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAE EE +EQTHISPNAIF\n"+
"Sbjct  19   LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEQEEGSEQTHISPNAIF  78\n"+
"\n"+
"Query  205  KALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGR  264\n"+
"            KALQADSP SSS MSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGK DLKREGRPL EG R\n"+
"Sbjct  79   KALQADSPQSSSSMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKQDLKREGRPLQEGAR  138\n"+
"\n"+
"Query  265  QPP-IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATH---GQVTYTGSYG  320\n"+
"            QPP IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP TH   GQVTYTGSYG\n"+
"Sbjct  139  QPPHIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPVTHGQPGQVTYTGSYG  198\n"+
"\n"+
"Query  321  ISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAH  380\n"+
"            ISST ATPA  GHVWMSKQQ                Q PP  Q     QP  P   P  H\n"+
"Sbjct  199  ISSTTATPAGTGHVWMSKQQ--------------QQQPPPSQQPPSQAQPQPPLPPPPQH  244\n"+
"\n"+
"Query  381  TLTTLSSEPGQ-SQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQ  439\n"+
"            TLTTLSSEPGQ  QRTHIKTEQLSPSHY++QQQHSPQQI+YS FNL HY  SYP ITRSQ\n"+
"Sbjct  245  TLTTLSSEPGQPQQRTHIKTEQLSPSHYTDQQQHSPQQISYSSFNLQHYGSSYPTITRSQ  304\n"+
"\n"+
"Query  440  YDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWE  499\n"+
"            YDYTDHQ+S++YYSHAA Q + LYSTFTYMNP QRPMYTPIADT+GVPSIPQTHSPQHWE\n"+
"Sbjct  305  YDYTDHQSSNTYYSHAASQSSSLYSTFTYMNPTQRPMYTPIADTTGVPSIPQTHSPQHWE  364\n"+
"\n"+
"Query  500  QPVYTQLTRP  509\n"+
"            QPVYTQLTRP\n"+
"Sbjct  365  QPVYTQLTRP  374\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ADJ96869.1<a name=ADJ96869></a> Sox9b [Clarias gariepinus]  \n"+
"Length=458\n"+
"\n"+
" Score = 528 bits (1361),  Expect = 0.0, Method: Compositional matrix adjust.\n"+
" Identities = 324/537 (60%), Positives = 359/537 (67%), Gaps = 107/537 (20%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGS----DTENTRPQENTFPKG  56\n"+
"            MNLLDPF+KMTDEQ+K LS APSP+MSEDSAGSPCPS SGS    D E           G\n"+
"Sbjct  1    MNLLDPFLKMTDEQDKSLSDAPSPSMSEDSAGSPCPSASGSGSCSDVETGGGVRARDVGG  60\n"+
"\n"+
"Query  57   EPDLKKESEED------KFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMN  110\n"+
"            E  LKK   ED      KFP CIREAVSQVLKGYDWTLVP+PVRV+G+SKNKPHVKRPMN\n"+
"Sbjct  61   E--LKKLDGEDEHENNEKFPQCIREAVSQVLKGYDWTLVPVPVRVHGASKNKPHVKRPMN  118\n"+
"\n"+
"Query  111  AFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHP  170\n"+
"            AFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLN++EKRPFVEEAERLRVQHKKDHP\n"+
"Sbjct  119  AFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNDTEKRPFVEEAERLRVQHKKDHP  178\n"+
"\n"+
"Query  171  DYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKAL-QADSPHSSSGMSEVHSPGEHSG  229\n"+
"            DYKYQPRRRKS KNGQ E EE  E TH+S NAIFKAL QADSP SS  M EVHSP E SG\n"+
"Sbjct  179  DYKYQPRRRKSAKNGQGEGEEGPEHTHVSTNAIFKALQQADSPASS--MGEVHSPSEQSG  236\n"+
"\n"+
"Query  230  QSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGG---------RQPPIDFRDVDIGELSS  280\n"+
"            QSQGPPTPPTTPK D Q GK++ KREGRPL +G          RQ  IDFRDVD+GELSS\n"+
"Sbjct  237  QSQGPPTPPTTPKIDAQAGKSEPKREGRPLQDGTAVTVGSGGQRQLNIDFRDVDLGELSS  296\n"+
"\n"+
"Query  281  DVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQ  340\n"+
"            DVIS++E+FDV EFDQYLPPNGHPG    HG ++               SA   WM+K  \n"+
"Sbjct  297  DVISHMESFDVAEFDQYLPPNGHPG----HGWMS---------------SAASGWMTK--  335\n"+
"\n"+
"Query  341  APPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTE  400\n"+
"                          +P + PQ  A  P +                  +  Q + THIKTE\n"+
"Sbjct  336  --------------SPSSSPQVGATSPGE------------------DQSQQRTTHIKTE  363\n"+
"\n"+
"Query  401  QLSPSHYSEQQQHSPQQIAYSPFNLPHY-----SPSYPP-ITRSQYDYTDH-QNSSSYYS  453\n"+
"            QLSPSHY               FNL HY     S ++P  I+R QYDYT+    S+SYYS\n"+
"Sbjct  364  QLSPSHYGS-------------FNLQHYTTSTSSSAFPSCISRPQYDYTEQPAGSASYYS  410\n"+
"\n"+
"Query  454  HAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWE-QPVYTQLTRP  509\n"+
"               GQG+ LYSTF YM+ +QRPMYTPI +T         HSPQHW+ QPVYTQL+ P\n"+
"Sbjct  411  --VGQGS-LYSTFNYMSSSQRPMYTPITETQ------SGHSPQHWDQQPVYTQLSGP  458\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007099260.2<a name=XP_007099260></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-9, partial \n"+
"[Panthera tigris altaica]  \n"+
"Length=294\n"+
"\n"+
" Score = 509 bits (1312),  Expect = 2e-178, Method: Compositional matrix adjust.\n"+
" Identities = 279/332 (84%), Positives = 282/332 (85%), Gaps = 40/332 (12%)\n"+
"\n"+
"Query  179  RKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPG-EHSGQSQGPPTP  237\n"+
"            RKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPG EHSGQSQGPPTP\n"+
"Sbjct  2    RKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGGEHSGQSQGPPTP  61\n"+
"\n"+
"Query  238  PTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQY  297\n"+
"            PTTPKTDVQPGKADLK EGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQY\n"+
"Sbjct  62   PTTPKTDVQPGKADLKPEGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQY  121\n"+
"\n"+
"Query  298  LPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQ  357\n"+
"            LPPNGHPGVPATHGQVTYTGSYGI+STAATP                             \n"+
"Sbjct  122  LPPNGHPGVPATHGQVTYTGSYGINSTAATPTGX--------------------------  155\n"+
"\n"+
"Query  358  APPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQ  417\n"+
"                          APPQ   AHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQ\n"+
"Sbjct  156  -------------XAPPQPQAAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQ  202\n"+
"\n"+
"Query  418  IAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMY  477\n"+
"            IAYSPFNLPHYSPSYPPITRSQYDYTDHQNS SYYSHAAGQG+ LYSTF+YMNPAQRPMY\n"+
"Sbjct  203  IAYSPFNLPHYSPSYPPITRSQYDYTDHQNSGSYYSHAAGQGSSLYSTFSYMNPAQRPMY  262\n"+
"\n"+
"Query  478  TPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            TPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  263  TPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  294\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ABC58685.1<a name=ABC58685></a> HMG box protein SoxE3 [Petromyzon marinus]  \n"+
"Length=539\n"+
"\n"+
" Score = 512 bits (1318),  Expect = 1e-175, Method: Compositional matrix adjust.\n"+
" Identities = 320/583 (55%), Positives = 365/583 (63%), Gaps = 128/583 (22%)\n"+
"\n"+
"Query  10   MTDEQ-EKGLSGAPSPTMSED-SAGSPCPSGSGSDTENTRPQENTFPKGEPDL-------  60\n"+
"            M+DEQ +K +S  PSP MSE+ S GSP  S +GSD+++           E          \n"+
"Sbjct  2    MSDEQHDKHMSDVPSPDMSENCSVGSPADSLAGSDSDSQSCGSKRCSDREDGAGASGLLL  61\n"+
"\n"+
"Query  61   -----------------------KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNG  97\n"+
"                                   KK  E+DKFP CIREAVSQVLKGYDWTLVPMPVRVNG\n"+
"Sbjct  62   AGGPGGVLDGGVVFGLGRDAGSGKKMDEDDKFPACIREAVSQVLKGYDWTLVPMPVRVNG  121\n"+
"\n"+
"Query  98   SSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEE  157\n"+
"            SSK+KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLL+E+EKRPFVEE\n"+
"Sbjct  122  SSKSKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLSENEKRPFVEE  181\n"+
"\n"+
"Query  158  AERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSG  217\n"+
"            AERLRVQHKKDHPDYKYQPRRRKS KNGQ+E++ + EQTHI+ NAI+KALQADSP     \n"+
"Sbjct  182  AERLRVQHKKDHPDYKYQPRRRKSGKNGQSESDSSGEQTHITTNAIYKALQADSP-----  236\n"+
"\n"+
"Query  218  MSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGE  277\n"+
"             ++VHSPGEHSGQSQGPPTPPTTPKTDVQ  K D+KREGRPL EGGRQ  IDF +VDI E\n"+
"Sbjct  237  SADVHSPGEHSGQSQGPPTPPTTPKTDVQSNKLDIKREGRPLQEGGRQ-QIDFSNVDIRE  295\n"+
"\n"+
"Query  278  LSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMS  337\n"+
"            LS +VISN+E+FDVNEFDQYLPPNGHPG    HGQ +   SYG +  +      GH W+S\n"+
"Sbjct  296  LSREVISNMESFDVNEFDQYLPPNGHPG----HGQ-SVAASYGGTGYSIN----GHAWLS  346\n"+
"\n"+
"Query  338  KQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQS----Q  393\n"+
"            KQQ                                  QQ Q HTL++    P       Q\n"+
"Sbjct  347  KQQ------------------------------QQQQQQQQQHTLSSPPPPPPAISSPEQ  376\n"+
"\n"+
"Query  394  RTHIKTEQLSPSHYSEQQQHSPQQI-----------------------------------  418\n"+
"            R H+KTEQLSPSHYS+QQQ   Q                                     \n"+
"Sbjct  377  RAHVKTEQLSPSHYSDQQQQQQQPQQQQQHSPQQQQQQQQQQPQQAQQAQQQVQQQQQLG  436\n"+
"\n"+
"Query  419  AYSPFNLPHYSPS-YPPITRSQ-----------YDYTDHQNSSSYYSHAAGQGTGLYSTF  466\n"+
"             YSPF++ HY  +  P I+RSQ           +  +    ++ Y  H+AGQ  GLYS F\n"+
"Sbjct  437  GYSPFSIQHYGAAVVPAISRSQYSYADHHHHHHHHQSSAAAAAYYSGHSAGQTAGLYSGF  496\n"+
"\n"+
"Query  467  TYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            +YM P+QRP YTPIAD +GVPSIPQ HSP  WEQPVYTQLTRP\n"+
"Sbjct  497  SYMGPSQRPSYTPIADATGVPSIPQPHSPPSWEQPVYTQLTRP  539\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ABQ44208.1<a name=ABQ44208></a> SRY-box containing gene 9, partial [Aspidoscelis inornata]  \n"+
"Length=321\n"+
"\n"+
" Score = 497 bits (1279),  Expect = 6e-173, Method: Compositional matrix adjust.\n"+
" Identities = 283/331 (85%), Positives = 283/331 (85%), Gaps = 15/331 (5%)\n"+
"\n"+
"Query  79   QVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKT  138\n"+
"            QVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKT\n"+
"Sbjct  1    QVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKT  60\n"+
"\n"+
"Query  139  LGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHI  198\n"+
"            LGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAE EE TEQTHI\n"+
"Sbjct  61   LGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEQEEGTEQTHI  120\n"+
"\n"+
"Query  199  SPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRP  258\n"+
"            SPNAIFKALQADSP SSS MSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGK DLKREGRP\n"+
"Sbjct  121  SPNAIFKALQADSPQSSSSMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKQDLKREGRP  180\n"+
"\n"+
"Query  259  LPEGGRQPP-IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATH---GQVT  314\n"+
"            L EGGRQPP IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP TH   GQVT\n"+
"Sbjct  181  LQEGGRQPPHIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPVTHGQPGQVT  240\n"+
"\n"+
"Query  315  YTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPP  374\n"+
"            YTGSYGIS T ATP   GHVWMSKQQ             P  Q PP     PP     P \n"+
"Sbjct  241  YTGSYGISGTTATPPGNGHVWMSKQQP----------QQPPSQQPPAQAQQPPPPQQQPT  290\n"+
"\n"+
"Query  375  QQPQAHTLTTLSSEPGQ-SQRTHIKTEQLSP  404\n"+
"            Q  Q HTLTTLSSEPGQ  QRTHIKTEQLSP\n"+
"Sbjct  291  QAQQQHTLTTLSSEPGQPQQRTHIKTEQLSP  321\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015718433.1<a name=XP_015718433></a> PREDICTED: transcription factor SOX-10 [Coturnix japonica]  \n"+
"Length=565\n"+
"\n"+
" Score = 468 bits (1204),  Expect = 4e-158, Method: Compositional matrix adjust.\n"+
" Identities = 271/496 (55%), Positives = 329/496 (66%), Gaps = 65/496 (13%)\n"+
"\n"+
"Query  21   APSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQV  80\n"+
"            +P P+M+ DS+     SG+G   +  + Q+++          E+++DKFPVCIREAVSQV\n"+
"Sbjct  128  SPGPSMASDSSPHLAGSGNGEMGKVKKEQQDS----------EADDDKFPVCIREAVSQV  177\n"+
"\n"+
"Query  81   LKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG  140\n"+
"            L GYDWTLVPMPVRVNGS+K+KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG\n"+
"Sbjct  178  LSGYDWTLVPMPVRVNGSNKSKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG  237\n"+
"\n"+
"Query  141  KLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISP  200\n"+
"            KLWRLLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+ K  Q E E   E      \n"+
"Sbjct  238  KLWRLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKNGKATQGEGEGQVEGEAGGA  297\n"+
"\n"+
"Query  201  NAI---FKALQADSPHSSSG--MSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKRE  255\n"+
"             AI   +K    D  H   G  MS+ H P   SGQS GPPTPPTTPKT++Q GKAD KRE\n"+
"Sbjct  298  AAIQAHYKNTHLDHRHPGEGSPMSDGH-PEHSSGQSHGPPTPPTTPKTELQAGKADSKRE  356\n"+
"\n"+
"Query  256  GRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTY  315\n"+
"            GR L EGG+ P IDF +VDIGE+S +V+SN+ETFDVNEFDQYLPPNGH G P   G    \n"+
"Sbjct  357  GRSLGEGGK-PHIDFGNVDIGEISHEVMSNMETFDVNEFDQYLPPNGHAGHPGHVGGYAA  415\n"+
"\n"+
"Query  316  TGSYGISSTAATPASAGH-VWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPP  374\n"+
"               YG+ S  A  A++GH  W+SKQ                                   \n"+
"Sbjct  416  ATGYGLGSALA--AASGHSAWISKQHG---------------------------------  440\n"+
"\n"+
"Query  375  QQPQAHTLTTLSSEPGQSQRTHIKTEQLSP-SHYSEQQQHSPQQIAYSPFNLPHYSPSYP  433\n"+
"                     + ++ P    +  +KTE  +P  HY++Q   S  QIAY+  +LPHY  ++P\n"+
"Sbjct  441  ------VSLSATTSPVVDSKAQVKTEGSAPGGHYTDQP--STSQIAYTSLSLPHYGSAFP  492\n"+
"\n"+
"Query  434  PITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTH  493\n"+
"             I+R Q+DY DHQ S  YYSH++ Q +GLYS F+YM P+QRP+YT I+D +  PS+PQ+H\n"+
"Sbjct  493  SISRPQFDYPDHQPSGPYYSHSS-QASGLYSAFSYMGPSQRPLYTAISDPA--PSVPQSH  549\n"+
"\n"+
"Query  494  SPQHWEQPVYTQLTRP  509\n"+
"            SP HWEQPVYT L+RP\n"+
"Sbjct  550  SPTHWEQPVYTTLSRP  565\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KFQ49910.1<a name=KFQ49910></a> Transcription factor SOX-9, partial [Nestor notabilis]  \n"+
"Length=262\n"+
"\n"+
" Score = 452 bits (1164),  Expect = 2e-156, Method: Compositional matrix adjust.\n"+
" Identities = 232/274 (85%), Positives = 242/274 (88%), Gaps = 17/274 (6%)\n"+
"\n"+
"Query  57   EPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWA  116\n"+
"            +PDLKKES+EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWA\n"+
"Sbjct  1    DPDLKKESDEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWA  60\n"+
"\n"+
"Query  117  QAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQP  176\n"+
"            QAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQP\n"+
"Sbjct  61   QAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQP  120\n"+
"\n"+
"Query  177  RRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPT  236\n"+
"            RRRKSVKNGQ+E EE TEQTHISPNAIFKALQADSP SSS +SEVHSPGEHSG+ QG P \n"+
"Sbjct  121  RRRKSVKNGQSEQEEGTEQTHISPNAIFKALQADSPQSSSSISEVHSPGEHSGEGQGCPL  180\n"+
"\n"+
"Query  237  PPTTPKTDVQPGKADLKREGRPL-PEGGRQPP-IDFRDVDIGELSSDVISNIETFDVNEF  294\n"+
"            P              L ++  P+  +  RQPP IDFRDVDIGELSSDVISNIETFDVNEF\n"+
"Sbjct  181  PIA------------LVQQCAPMGAKAARQPPHIDFRDVDIGELSSDVISNIETFDVNEF  228\n"+
"\n"+
"Query  295  DQYLPPNGHPGVPATH---GQVTYTGSYGISSTA  325\n"+
"            DQYLPPNGHPGVPATH   GQVTYTGSYGISST+\n"+
"Sbjct  229  DQYLPPNGHPGVPATHGQPGQVTYTGSYGISSTS  262\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAG11536.1<a name=BAG11536></a> Sry-box protein 9 [Eptatretus burgeri]  \n"+
"Length=498\n"+
"\n"+
" Score = 451 bits (1160),  Expect = 2e-152, Method: Compositional matrix adjust.\n"+
" Identities = 292/555 (53%), Positives = 340/555 (61%), Gaps = 112/555 (20%)\n"+
"\n"+
"Query  10   MTDEQEKGLSGAPSPTMSE-DSAGSPCPSGSGSDTENTRPQENTF-----------PKGE  57\n"+
"            M DE+   +S  PSP +SE  S GS   S +GS+T++                      E\n"+
"Sbjct  1    MEDER---MSATPSPALSEHSSVGSTVDSFAGSETDSQGSARRGLLDEAAGGSGSSAGRE  57\n"+
"\n"+
"Query  58   PDLKKESEED-KFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWA  116\n"+
"               K  SE+D KFP CIREAVSQVLKGYDWTLVPMPVRVNGSSK KPHVKRPMNAFMVWA\n"+
"Sbjct  58   STRKASSEDDDKFPACIREAVSQVLKGYDWTLVPMPVRVNGSSKAKPHVKRPMNAFMVWA  117\n"+
"\n"+
"Query  117  QAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQP  176\n"+
"            QAARRKLADQYPHLHNAELSKTLGKLWRLL+E+EKRPFVEEAERLRVQHKKDHPDYKYQP\n"+
"Sbjct  118  QAARRKLADQYPHLHNAELSKTLGKLWRLLSENEKRPFVEEAERLRVQHKKDHPDYKYQP  177\n"+
"\n"+
"Query  177  RRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPT  236\n"+
"            RRRK+ K G A+A+   E +H +P +++KAL   SPHS+    +VHSP +HSG SQGPPT\n"+
"Sbjct  178  RRRKAGKGGPADADGIGEDSHPAPGSLYKALTG-SPHSA---PDVHSPSDHSGNSQGPPT  233\n"+
"\n"+
"Query  237  PPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQ  296\n"+
"            PPTTPKT+V   K D+KREGRPL EGGRQ  IDF +VDI ELS +VISN+E+FDVNEFDQ\n"+
"Sbjct  234  PPTTPKTEVHGNKLDIKREGRPLQEGGRQ-HIDFSNVDIRELSREVISNMESFDVNEFDQ  292\n"+
"\n"+
"Query  297  YLPPNGHPGVPATHGQVTYT--GSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPP  354\n"+
"            Y PPNGHP      GQ  Y     YG+     TP    H W++                P\n"+
"Sbjct  293  YRPPNGHP------GQGVYAPPSVYGLVG-GGTP----HTWLT----------------P  325\n"+
"\n"+
"Query  355  APQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHS  414\n"+
"              + P    +AP              + + +++E     RTH+KTEQLSPSHYS+ Q   \n"+
"Sbjct  326  GTKTPLPAPSAP--------------SSSPMNAE----VRTHVKTEQLSPSHYSDTQAAQ  367\n"+
"\n"+
"Query  415  PQQIA----------------------------------YSPFNLPHYSPS-YPPITRSQ  439\n"+
"             Q                                     Y PFNL HY  +  P ITRSQ\n"+
"Sbjct  368  VQTQTGQQPHQQQQQQQQQQSQQQQHSPPQSQQHPHLGNYIPFNLQHYGATVVPTITRSQ  427\n"+
"\n"+
"Query  440  YDYTD----HQNSSSYYSHAAGQGTG-LYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHS  494\n"+
"            Y Y+D    HQ    Y  H +G   G LYSTF+YM P+QR  YTP+A+ +   S+P THS\n"+
"Sbjct  428  YSYSDPHGPHQG-GYYGGHISGAQPGALYSTFSYMGPSQRASYTPVAEAA---SLPPTHS  483\n"+
"\n"+
"Query  495  PQHWEQPVYTQLTRP  509\n"+
"            P  WEQPVYTQLTRP\n"+
"Sbjct  484  PPPWEQPVYTQLTRP  498\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAI70062.1<a name=AAI70062></a> LOC398422 protein [Xenopus laevis]  \n"+
"Length=448\n"+
"\n"+
" Score = 449 bits (1154),  Expect = 4e-152, Method: Compositional matrix adjust.\n"+
" Identities = 262/456 (57%), Positives = 308/456 (68%), Gaps = 66/456 (14%)\n"+
"\n"+
"Query  60   LKKE--SEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQ  117\n"+
"            +KKE  SE+++FPVCIREAVSQVL GYDWTLVPMPVRVNG SK+KPHVKRPMNAFMVWAQ\n"+
"Sbjct  53   VKKEQDSEDERFPVCIREAVSQVLNGYDWTLVPMPVRVNGGSKSKPHVKRPMNAFMVWAQ  112\n"+
"\n"+
"Query  118  AARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPR  177\n"+
"            AARRKLADQYPHLHNAELSKTLGKLWRLLNE++KRPF+EEAERLR+QHKKDHPDYKYQPR\n"+
"Sbjct  113  AARRKLADQYPHLHNAELSKTLGKLWRLLNENDKRPFIEEAERLRMQHKKDHPDYKYQPR  172\n"+
"\n"+
"Query  178  RRKSVK--NGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHS-GQSQGP  234\n"+
"            RRK+ K   G+ +     E    S  A +K    D  H S  MS+ +S  EHS GQS GP\n"+
"Sbjct  173  RRKNGKPSPGEGDGSSEAEGGAASIQAHYKNSHLDHRHGSP-MSDGNS--EHSTGQSHGP  229\n"+
"\n"+
"Query  235  PTPPTTPKTDVQPGKADLKREG-RPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNE  293\n"+
"            PTPPTTPKT++Q GK+D KR+G   L EGG+ P IDF +VDIGE+S DV+SN+ETFDVNE\n"+
"Sbjct  230  PTPPTTPKTELQAGKSDGKRDGSHALREGGK-PQIDFGNVDIGEISHDVMSNMETFDVNE  288\n"+
"\n"+
"Query  294  FDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAP  353\n"+
"            FDQYLPPNGH G P+  G   YT SYG++   A   SA   W   +Q             \n"+
"Sbjct  289  FDQYLPPNGHAGHPSHIG--GYTSSYGLTGALAAGPSA---WALAKQ-------------  330\n"+
"\n"+
"Query  354  PAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQH  413\n"+
"                                      H+ T   S      +  +KTE  S SHY+EQ   \n"+
"Sbjct  331  --------------------------HSQTVADS------KAQVKTESSSTSHYTEQP--  356\n"+
"\n"+
"Query  414  SPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQ  473\n"+
"            S  Q+ Y+   LPHY  ++P I+R Q+DY DHQ SSSYYSH+A Q + LYS F+YM P Q\n"+
"Sbjct  357  STSQLTYTSLGLPHYGSAFPSISRPQFDYADHQPSSSYYSHSA-QASSLYSAFSYMGPPQ  415\n"+
"\n"+
"Query  474  RPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            RP+YT I+D    PS+ Q+HSP HWEQPVYT L+RP\n"+
"Sbjct  416  RPLYTAISDP---PSVAQSHSPTHWEQPVYTTLSRP  448\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015314502.1<a name=XP_015314502></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-9 isoform \n"+
"X1 [Bos taurus]  \n"+
"Length=353\n"+
"\n"+
" Score = 439 bits (1129),  Expect = 1e-149, Method: Compositional matrix adjust.\n"+
" Identities = 215/230 (93%), Positives = 218/230 (95%), Gaps = 0/230 (0%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDPFMKMTDEQEKGLS APSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL\n"+
"Sbjct  1    MNLLDPFMKMTDEQEKGLSAAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNA+MVWA AAR\n"+
"Sbjct  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAYMVWAHAAR  120\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLH   LS +     RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  121  RKLADQYPHLHTQPLSLSPRAAPRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQ  230\n"+
"            SVKNGQAEAEEA EQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSG+\n"+
"Sbjct  181  SVKNGQAEAEEAPEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGE  230\n"+
"\n"+
"\n"+
" Score = 81.6 bits (200),  Expect = 6e-14, Method: Compositional matrix adjust.\n"+
" Identities = 37/41 (90%), Positives = 38/41 (93%), Gaps = 0/41 (0%)\n"+
"\n"+
"Query  469  MNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            M   +RPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  313  MQGGRRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  353\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AGZ80879.1<a name=AGZ80879></a> Sox9a variant 6, partial [Carassius auratus ssp. 'Pengze']  \n"+
"Length=319\n"+
"\n"+
" Score = 435 bits (1119),  Expect = 7e-149, Method: Compositional matrix adjust.\n"+
" Identities = 259/436 (59%), Positives = 279/436 (64%), Gaps = 124/436 (28%)\n"+
"\n"+
"Query  81   LKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG  140\n"+
"            LKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG\n"+
"Sbjct  1    LKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG  60\n"+
"\n"+
"Query  141  KLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISP  200\n"+
"            KLWRLLNE EKRPFVEEAERLRVQHKKDHPDYKYQ                         \n"+
"Sbjct  61   KLWRLLNEGEKRPFVEEAERLRVQHKKDHPDYKYQ-------------------------  95\n"+
"\n"+
"Query  201  NAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLP  260\n"+
"                                   PGEHSGQSQGPPTPPTTPKTD QPGK DLKRE RPL \n"+
"Sbjct  96   -----------------------PGEHSGQSQGPPTPPTTPKTDAQPGKVDLKREARPLQ  132\n"+
"\n"+
"Query  261  EG-GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSY  319\n"+
"            E  GR   IDFRDVDIGELSSDV   IETFDVNEFDQYLPPNGH                \n"+
"Sbjct  133  ESTGRPLNIDFRDVDIGELSSDV---IETFDVNEFDQYLPPNGH----------------  173\n"+
"\n"+
"Query  320  GISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQA  379\n"+
"                  AT AS    WM K Q   P  Q+ P+A                           \n"+
"Sbjct  174  ------ATNASYYATWMGKPQNGSPGEQEQPRA---------------------------  200\n"+
"\n"+
"Query  380  HTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFN---LPHYSPSYPPIT  436\n"+
"                           THIKTEQLSPSHY++Q   SPQQ +Y  FN   L HYS S+P IT\n"+
"Sbjct  201  ---------------THIKTEQLSPSHYNDQG--SPQQASYGSFNVQHLQHYSTSFPSIT  243\n"+
"\n"+
"Query  437  RSQYDYTDHQ-NSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQT-HS  494\n"+
"            R+QYDY+DHQ  ++SYY+HA GQ +GLYSTF+Y++P+ RPMYTPIAD++GVPSIPQT HS\n"+
"Sbjct  244  RAQYDYSDHQGGANSYYTHAGGQSSGLYSTFSYISPSPRPMYTPIADSAGVPSIPQTNHS  303\n"+
"\n"+
"Query  495  PQHWE-QPVYTQLTRP  509\n"+
"            PQHW+ QPVYTQL+RP\n"+
"Sbjct  304  PQHWDQQPVYTQLSRP  319\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_571719.1<a name=NP_571719></a> SRY (sex determining region Y)-box 9b [Danio rerio]\n"+
" AAG09815.1<a name=AAG09815></a> HMG box transcription factor Sox9b [Danio rerio]  \n"+
"Length=407\n"+
"\n"+
" Score = 432 bits (1110),  Expect = 4e-146, Method: Compositional matrix adjust.\n"+
" Identities = 291/513 (57%), Positives = 331/513 (65%), Gaps = 110/513 (21%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPS-GSGSDTENTRPQENTFPKGEPD  59\n"+
"            MNLL   +KM+      +SGAPSP++SEDSAGSPC S GSGSD+E         P+ EP \n"+
"Sbjct  1    MNLLQRGLKMS------VSGAPSPSLSEDSAGSPCASAGSGSDSET--------PRAEPP  46\n"+
"\n"+
"Query  60   LKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAA  119\n"+
"            L ++ E++KFPVCIR+AVSQVLKGYDW+LVPMPVRV+GS K+KPHVKRPMNAFMVWAQAA\n"+
"Sbjct  47   LHRD-EQEKFPVCIRDAVSQVLKGYDWSLVPMPVRVSGSGKSKPHVKRPMNAFMVWAQAA  105\n"+
"\n"+
"Query  120  RRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            RRKLADQYPHLHNAELSKTLGKLWRLLNE EKRPFVEEAERLRVQHKKDHPDYKYQPRRR\n"+
"Sbjct  106  RRKLADQYPHLHNAELSKTLGKLWRLLNEGEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  165\n"+
"\n"+
"Query  180  KSVKNGQAEAEEATEQTHISPNAIFKALQ-ADSPHSSSGMSEVHSPGEHSGQSQGPPTPP  238\n"+
"            KSVK+G AE+E+  EQT IS NA+F+ALQ A++P SS+G  E+HSPGEHSGQSQGPPTPP\n"+
"Sbjct  166  KSVKSGSAESEDG-EQTQISTNALFRALQRAETPDSSTG--ELHSPGEHSGQSQGPPTPP  222\n"+
"\n"+
"Query  239  TTPKTDV-QPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQY  297\n"+
"            TTPKTD+    KADLKRE     E   Q  IDF  VDIGELSSDVISNIE FDVNEFDQY\n"+
"Sbjct  223  TTPKTDLPVCSKADLKRERERDRERPLQDGIDFGAVDIGELSSDVISNIEAFDVNEFDQY  282\n"+
"\n"+
"Query  298  LPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQ  357\n"+
"            LPP+G PG PA  G   ++  YG ++           WM K                   \n"+
"Sbjct  283  LPPHGAPG-PAGAG---FSSGYGSAA-----------WMHK-------------------  308\n"+
"\n"+
"Query  358  APPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQ  417\n"+
"                               P A +    + E  Q QR  IKTEQLSP HYS+Q    PQQ\n"+
"Sbjct  309  -------------------PLASSSMANAGEQHQ-QRAQIKTEQLSPGHYSQQ---PPQQ  345\n"+
"\n"+
"Query  418  IAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMY  477\n"+
"              YS            P +R+QY     Q+ S+YYS         Y TF+Y     RP Y\n"+
"Sbjct  346  QFYS-----------APYSRAQYTEYSEQH-SAYYSP--------YPTFSY----SRPPY  381\n"+
"\n"+
"Query  478  TPIADTSGVPSIPQTHSPQHWE-QPVYTQLTRP  509\n"+
"            TP A          T    HW+ QPVYTQL+RP\n"+
"Sbjct  382  TPAAAAD-------TAHTHHWDPQPVYTQLSRP  407\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAH04064.1<a name=AAH04064></a> Sox9 protein, partial [Mus musculus]  \n"+
"Length=262\n"+
"\n"+
" Score = 421 bits (1081),  Expect = 6e-144, Method: Compositional matrix adjust.\n"+
" Identities = 245/264 (93%), Positives = 248/264 (94%), Gaps = 2/264 (1%)\n"+
"\n"+
"Query  246  QPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPG  305\n"+
"            Q GK DLKREGRPL EGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPG\n"+
"Sbjct  1    QAGKVDLKREGRPLAEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPG  60\n"+
"\n"+
"Query  306  VPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAA  365\n"+
"            VPATHGQVTYTGSYGISSTA TPA+AGHVWMSKQQAPPPPPQQPPQAP APQAPPQ QA \n"+
"Sbjct  61   VPATHGQVTYTGSYGISSTAPTPATAGHVWMSKQQAPPPPPQQPPQAPQAPQAPPQQQAP  120\n"+
"\n"+
"Query  366  PPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNL  425\n"+
"            P Q  A   QQ QAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQI+YSPFNL\n"+
"Sbjct  121  PQQPQAP--QQQQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQISYSPFNL  178\n"+
"\n"+
"Query  426  PHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSG  485\n"+
"            PHYSPSYPPITRSQYDY DHQNS SYYSHAAGQG+GLYSTFTYMNPAQRPMYTPIADTSG\n"+
"Sbjct  179  PHYSPSYPPITRSQYDYADHQNSGSYYSHAAGQGSGLYSTFTYMNPAQRPMYTPIADTSG  238\n"+
"\n"+
"Query  486  VPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            VPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  239  VPSIPQTHSPQHWEQPVYTQLTRP  262\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EHH25156.1<a name=EHH25156></a> hypothetical protein EGK_08928, partial [Macaca mulatta]  \n"+
"Length=356\n"+
"\n"+
" Score = 418 bits (1075),  Expect = 2e-141, Method: Compositional matrix adjust.\n"+
" Identities = 209/209 (100%), Positives = 209/209 (100%), Gaps = 0/209 (0%)\n"+
"\n"+
"Query  90   PMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNES  149\n"+
"            PMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNES\n"+
"Sbjct  1    PMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNES  60\n"+
"\n"+
"Query  150  EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQA  209\n"+
"            EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQA\n"+
"Sbjct  61   EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQA  120\n"+
"\n"+
"Query  210  DSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPID  269\n"+
"            DSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPID\n"+
"Sbjct  121  DSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPID  180\n"+
"\n"+
"Query  270  FRDVDIGELSSDVISNIETFDVNEFDQYL  298\n"+
"            FRDVDIGELSSDVISNIETFDVNEFDQYL\n"+
"Sbjct  181  FRDVDIGELSSDVISNIETFDVNEFDQYL  209\n"+
"\n"+
"\n"+
" Score = 268 bits (686),  Expect = 5e-83, Method: Compositional matrix adjust.\n"+
" Identities = 130/130 (100%), Positives = 130/130 (100%), Gaps = 0/130 (0%)\n"+
"\n"+
"Query  380  HTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQ  439\n"+
"            HTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQ\n"+
"Sbjct  227  HTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQ  286\n"+
"\n"+
"Query  440  YDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWE  499\n"+
"            YDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWE\n"+
"Sbjct  287  YDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWE  346\n"+
"\n"+
"Query  500  QPVYTQLTRP  509\n"+
"            QPVYTQLTRP\n"+
"Sbjct  347  QPVYTQLTRP  356\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007622861.1<a name=XP_007622861></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-10 isoform \n"+
"X2 [Cricetulus griseus]  \n"+
"Length=597\n"+
"\n"+
" Score = 422 bits (1085),  Expect = 1e-139, Method: Compositional matrix adjust.\n"+
" Identities = 247/434 (57%), Positives = 286/434 (66%), Gaps = 58/434 (13%)\n"+
"\n"+
"Query  84   YDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLW  143\n"+
"            YDWTLVPMPVRVNG+SK+KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLW\n"+
"Sbjct  214  YDWTLVPMPVRVNGASKSKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLW  273\n"+
"\n"+
"Query  144  RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAE----EATEQTHIS  199\n"+
"            RLLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+ K  Q EAE    EA +    +\n"+
"Sbjct  274  RLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKNGKAAQGEAECPGGEAEQGGAAA  333\n"+
"\n"+
"Query  200  PNAIFKALQADSPHSSSGMSEVHSPGEH-SGQSQGPPTPPTTPKTDVQPGKADLKREGRP  258\n"+
"              A +K+   D  H   G        EH SGQS GPPTPPTTPKT++Q GKAD KR+GR \n"+
"Sbjct  334  IQAHYKSAHLDHRHPEEGSPMSDGNPEHPSGQSHGPPTPPTTPKTELQSGKADPKRDGRS  393\n"+
"\n"+
"Query  259  LPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGS  318\n"+
"            L EGG+ P IDF +VDIGE+S +V+SN+ETFDV E DQYLPPNGHPG    H        \n"+
"Sbjct  394  LGEGGK-PHIDFGNVDIGEISHEVMSNMETFDVTELDQYLPPNGHPG----HVGSYSAAG  448\n"+
"\n"+
"Query  319  YGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQ  378\n"+
"            YG+ S  A  AS    W+SK    PP    P  +PP   A  Q                 \n"+
"Sbjct  449  YGLGSALAV-ASGHSAWISK----PPGVALPTVSPPGVDAKAQ-----------------  486\n"+
"\n"+
"Query  379  AHTLTTLSSEPGQSQRTHIKTEQLSPS---HYSEQQQHSPQQIAYSPFNLPHYSPSYPPI  435\n"+
"                              +KTE   P    HY++Q   S  QIAY+  +LPHY  ++P I\n"+
"Sbjct  487  ------------------VKTETTGPQGPPHYTDQP--STSQIAYTSLSLPHYGSAFPSI  526\n"+
"\n"+
"Query  436  TRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP  495\n"+
"            +R Q+DY+DHQ S  YY H AGQ +GLYS F+YM P+QRP+YT I+D S  PS PQ+HSP\n"+
"Sbjct  527  SRPQFDYSDHQPSGPYYGH-AGQASGLYSAFSYMGPSQRPLYTAISDPS--PSGPQSHSP  583\n"+
"\n"+
"Query  496  QHWEQPVYTQLTRP  509\n"+
"             HWEQPVYT L+RP\n"+
"Sbjct  584  THWEQPVYTTLSRP  597\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_008492897.1<a name=XP_008492897></a> PREDICTED: transcription factor SOX-9 [Calypte anna]  \n"+
"Length=345\n"+
"\n"+
" Score = 413 bits (1061),  Expect = 1e-139, Method: Compositional matrix adjust.\n"+
" Identities = 212/231 (92%), Positives = 225/231 (97%), Gaps = 0/231 (0%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDPFMKMT+EQ+K +S APSPTMS+DS+GSPCPSGSGSDTENTRPQENTFPKG+PDL\n"+
"Sbjct  1    MNLLDPFMKMTEEQDKCISDAPSPTMSDDSSGSPCPSGSGSDTENTRPQENTFPKGDPDL  60\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            KKE++EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  61   KKENDEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQS  231\n"+
"            SVKNGQ+E EE +EQTHISPNAIFKALQADSP SSS +SEVHSPGEHSG++\n"+
"Sbjct  181  SVKNGQSEQEEGSEQTHISPNAIFKALQADSPQSSSSISEVHSPGEHSGRT  231\n"+
"\n"+
"\n"+
" Score = 221 bits (563),  Expect = 6e-65, Method: Compositional matrix adjust.\n"+
" Identities = 108/122 (89%), Positives = 111/122 (91%), Gaps = 1/122 (1%)\n"+
"\n"+
"Query  389  PGQ-SQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQN  447\n"+
"            PG+ S RTHIKTEQLSPSHYSEQQQHSPQQ+ YS FNL HY  SYP ITRSQYDYTDHQN\n"+
"Sbjct  224  PGEHSGRTHIKTEQLSPSHYSEQQQHSPQQLNYSSFNLQHYGSSYPTITRSQYDYTDHQN  283\n"+
"\n"+
"Query  448  SSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLT  507\n"+
"            SSSYYSHAAGQ + LYSTFTYMNP QRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLT\n"+
"Sbjct  284  SSSYYSHAAGQSSSLYSTFTYMNPTQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLT  343\n"+
"\n"+
"Query  508  RP  509\n"+
"            RP\n"+
"Sbjct  344  RP  345\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014166731.1<a name=XP_014166731></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-9-like \n"+
"[Geospiza fortis]  \n"+
"Length=399\n"+
"\n"+
" Score = 414 bits (1065),  Expect = 2e-139, Method: Compositional matrix adjust.\n"+
" Identities = 285/524 (54%), Positives = 308/524 (59%), Gaps = 140/524 (27%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDPFMKMT+EQ+K +S APSPTMS+DSAGSPCPSGSGSDTE TRP            \n"+
"Sbjct  1    MNLLDPFMKMTEEQDKCISDAPSPTMSDDSAGSPCPSGSGSDTEXTRP------------  48\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"                   +FP CIR+AVSQVLKGYDW+LVPMPVR NGS K KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  49   -------RFPACIRDAVSQVLKGYDWSLVPMPVRGNGSLKAKPHVKRPMNAFMVWAQAAR  101\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEK-----RPFVEEAERLRVQHKKDHPDYKYQ  175\n"+
"            RKLADQYPHLHNAELSKTLGKLWR +    +     RP  EE ER     +    D+   \n"+
"Sbjct  102  RKLADQYPHLHNAELSKTLGKLWRXVRGQREHLPQGRPGPEEGER-----RGQGYDWTLV  156\n"+
"\n"+
"Query  176  P---RRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQ  232\n"+
"            P   R   S KN                           PH   G               \n"+
"Sbjct  157  PMPVRVNGSSKN--------------------------KPHVKRGEE-------------  177\n"+
"\n"+
"Query  233  GPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPP-IDFRDVDIGELSSDVISNIETFDV  291\n"+
"                   T +TD QPGK DLKREGR L EGGRQPP IDFRDVDIGE SS           \n"+
"Sbjct  178  ------NTRRTDAQPGKQDLKREGRALGEGGRQPPHIDFRDVDIGERSS-----------  220\n"+
"\n"+
"Query  292  NEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQ  351\n"+
"                   PP G PG      QVTYTG+YGIS  A        VWMSKQQ   PP  Q P \n"+
"Sbjct  221  -------PPTGPPG------QVTYTGTYGISGAAG-------VWMSKQQQQQPPAAQLPA  260\n"+
"\n"+
"Query  352  APPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQ  411\n"+
"               A Q P Q Q                           Q QRTHIKTEQLSPSHYSEQQ\n"+
"Sbjct  261  LS-AEQGPQQQQQQQ------------------------QQQRTHIKTEQLSPSHYSEQQ  295\n"+
"\n"+
"Query  412  QHSPQQIAYSP-----FNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHA-AGQGTGLYST  465\n"+
"            QHSPQQ          FNL HYS SYP I+R+QY+Y +HQ SSS   ++ AGQG G+YST\n"+
"Sbjct  296  QHSPQQQQQQQLSYSSFNLQHYSSSYPSISRAQYEYGEHQGSSSGSYYSHAGQGGGIYST  355\n"+
"\n"+
"Query  466  FTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            F+YM+P QRPMYTPIADT+GVPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  356  FSYMSPTQRPMYTPIADTAGVPSIPQTHSPQHWEQPVYTQLTRP  399\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014059241.1<a name=XP_014059241></a> PREDICTED: transcription factor Sox-10-like [Salmo salar]  \n"+
"Length=496\n"+
"\n"+
" Score = 414 bits (1065),  Expect = 5e-138, Method: Compositional matrix adjust.\n"+
" Identities = 245/492 (50%), Positives = 307/492 (62%), Gaps = 93/492 (19%)\n"+
"\n"+
"Query  56   GEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVW  115\n"+
"            G   +K + ++D+FP+ IREAVSQVL GYDWTLVPMPVRVN  SK+KPHVKRPMNAFMVW\n"+
"Sbjct  60   GGISIKSDEDDDRFPIGIREAVSQVLNGYDWTLVPMPVRVNSGSKSKPHVKRPMNAFMVW  119\n"+
"\n"+
"Query  116  AQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQ  175\n"+
"            AQAARRKLADQYPHLHNAELSKTLGKLWRLLNES+K+PF+EEAERLR QHKKD+P+YKYQ\n"+
"Sbjct  120  AQAARRKLADQYPHLHNAELSKTLGKLWRLLNESDKKPFIEEAERLRKQHKKDYPEYKYQ  179\n"+
"\n"+
"Query  176  PRRRKSVK-------NGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEH-  227\n"+
"            PRRRK+ K       +G +E E +  QTH      +K+L  D      G     + G H \n"+
"Sbjct  180  PRRRKNGKPGSGSEADGHSEGEVSHSQTH------YKSLHLDVAAHVGGAGSPLADGHHP  233\n"+
"\n"+
"Query  228  --SGQSQGPPTPPTTPKTDVQPGK-ADLKREGRPLPEGGR---------------QPPID  269\n"+
"              +GQS  PPTPPTTPKT++Q GK  D KREG  +                    +P ID\n"+
"Sbjct  234  HTAGQSHSPPTPPTTPKTELQSGKLGDGKREGGGVGGSRGGMGVGVEGGSGSGSGKPHID  293\n"+
"\n"+
"Query  270  FRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTG----------SY  319\n"+
"            F +VDIGE+S +V++N+E FDVNEFDQYLPPNGHPG+    GQ   +           +Y\n"+
"Sbjct  294  FGNVDIGEISHEVMANMEPFDVNEFDQYLPPNGHPGI----GQSAGSAAAAGSSVSPYAY  349\n"+
"\n"+
"Query  320  GISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQA  379\n"+
"            GISS  A  +    VW+SKQ                                      Q \n"+
"Sbjct  350  GISSALAAASGHSAVWLSKQH-------------------------------------QQ  372\n"+
"\n"+
"Query  380  HTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPI-TRS  438\n"+
"            H  + L S+P ++Q   IK+E  S  H++E        + Y+P +LPHYS ++P + +R+\n"+
"Sbjct  373  HHASPLGSDPSKAQ---IKSEADSGGHFAEASS-GGSHVTYTPLSLPHYSSAFPSLASRA  428\n"+
"\n"+
"Query  439  QY-DYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQH  497\n"+
"            Q+ +Y DHQ S SYY+H++ Q +GLYS F+YM P+QRP+YT I D S   S+PQ+HSP H\n"+
"Sbjct  429  QFAEYADHQASGSYYAHSS-QASGLYSAFSYMGPSQRPLYTAITDPS---SVPQSHSPTH  484\n"+
"\n"+
"Query  498  WEQPVYTQLTRP  509\n"+
"            WEQPVYT L+RP\n"+
"Sbjct  485  WEQPVYTTLSRP  496\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AFX73410.1<a name=AFX73410></a> transcription factor Sox9, partial [Salvelinus alpinus]  \n"+
"Length=256\n"+
"\n"+
" Score = 401 bits (1031),  Expect = 2e-136, Method: Compositional matrix adjust.\n"+
" Identities = 215/258 (83%), Positives = 225/258 (87%), Gaps = 8/258 (3%)\n"+
"\n"+
"Query  18   LSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTF---PKGEPDLKKESEEDKFPVCIR  74\n"+
"             S APSP+MSEDS GSPCPSGSGSDTENTRP +N     P GE    K++++DKFPVCIR\n"+
"Sbjct  2    FSDAPSPSMSEDSVGSPCPSGSGSDTENTRPSDNHLLLGPDGELGEFKKADQDKFPVCIR  61\n"+
"\n"+
"Query  75   EAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAE  134\n"+
"            +AVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPH HNAE\n"+
"Sbjct  62   DAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHPHNAE  121\n"+
"\n"+
"Query  135  LSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATE  194\n"+
"            LSKTLGKLWRLLNE EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQ+E E+  E\n"+
"Sbjct  122  LSKTLGKLWRLLNEGEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQSEPEDG-E  180\n"+
"\n"+
"Query  195  QTHISPNAIFKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLK  253\n"+
"            QTHIS   IFKAL QADSP SS  M EVHSPGEHSGQSQGPPTPPTTPKTD+  GKADLK\n"+
"Sbjct  181  QTHISSGDIFKALRQADSPASS--MGEVHSPGEHSGQSQGPPTPPTTPKTDLAVGKADLK  238\n"+
"\n"+
"Query  254  REGRPLPEG-GRQPPIDF  270\n"+
"            REGRPL EG GRQ  IDF\n"+
"Sbjct  239  REGRPLQEGTGRQLNIDF  256\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAN66330.1<a name=BAN66330></a> transcription factor, partial [Homo sapiens]  \n"+
"Length=239\n"+
"\n"+
" Score = 400 bits (1028),  Expect = 3e-136, Method: Compositional matrix adjust.\n"+
" Identities = 201/201 (100%), Positives = 201/201 (100%), Gaps = 0/201 (0%)\n"+
"\n"+
"Query  230  QSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETF  289\n"+
"            QSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETF\n"+
"Sbjct  1    QSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETF  60\n"+
"\n"+
"Query  290  DVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQP  349\n"+
"            DVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQP\n"+
"Sbjct  61   DVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQP  120\n"+
"\n"+
"Query  350  PQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSE  409\n"+
"            PQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSE\n"+
"Sbjct  121  PQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSE  180\n"+
"\n"+
"Query  410  QQQHSPQQIAYSPFNLPHYSP  430\n"+
"            QQQHSPQQIAYSPFNLPHYSP\n"+
"Sbjct  181  QQQHSPQQIAYSPFNLPHYSP  201\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_016831152.1<a name=XP_016831152></a> PREDICTED: transcription factor SOX-9 isoform X1 [Cricetulus \n"+
"griseus]  \n"+
"Length=563\n"+
"\n"+
" Score = 402 bits (1033),  Expect = 2e-132, Method: Compositional matrix adjust.\n"+
" Identities = 191/191 (100%), Positives = 191/191 (100%), Gaps = 0/191 (0%)\n"+
"\n"+
"Query  39   SGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGS  98\n"+
"            SGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGS\n"+
"Sbjct  173  SGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGS  232\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA\n"+
"Sbjct  233  SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  292\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGM  218\n"+
"            ERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGM\n"+
"Sbjct  293  ERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGM  352\n"+
"\n"+
"Query  219  SEVHSPGEHSG  229\n"+
"            SEVHSPGEHSG\n"+
"Sbjct  353  SEVHSPGEHSG  363\n"+
"\n"+
"\n"+
" Score = 248 bits (632),  Expect = 1e-72, Method: Compositional matrix adjust.\n"+
" Identities = 127/130 (98%), Positives = 128/130 (98%), Gaps = 0/130 (0%)\n"+
"\n"+
"Query  380  HTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQ  439\n"+
"            HTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQ SPQQIAYSPFNLPHYSPSYPPITRSQ\n"+
"Sbjct  434  HTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQPSPQQIAYSPFNLPHYSPSYPPITRSQ  493\n"+
"\n"+
"Query  440  YDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWE  499\n"+
"            YDYTDHQNS SYYSHAAGQG+GLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWE\n"+
"Sbjct  494  YDYTDHQNSGSYYSHAAGQGSGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWE  553\n"+
"\n"+
"Query  500  QPVYTQLTRP  509\n"+
"            QPVYTQLTRP\n"+
"Sbjct  554  QPVYTQLTRP  563\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAG14376.1<a name=BAG14376></a> SoxE family protein E3, partial [Lethenteron camtschaticum]  \n"+
"\n"+
"Length=401\n"+
"\n"+
" Score = 394 bits (1012),  Expect = 2e-131, Method: Compositional matrix adjust.\n"+
" Identities = 254/445 (57%), Positives = 288/445 (65%), Gaps = 91/445 (20%)\n"+
"\n"+
"Query  112  FMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPD  171\n"+
"            FMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLL+E+EKRPFVEEAERLRVQHKKDHPD\n"+
"Sbjct  1    FMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLSENEKRPFVEEAERLRVQHKKDHPD  60\n"+
"\n"+
"Query  172  YKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQS  231\n"+
"            YKYQPRRRKS KNGQ+E++ + EQTHI+ NAI+KALQADSP   SG  +VHSPGEHSGQS\n"+
"Sbjct  61   YKYQPRRRKSGKNGQSESDSSGEQTHITTNAIYKALQADSP---SG--DVHSPGEHSGQS  115\n"+
"\n"+
"Query  232  QGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDV  291\n"+
"            QGPPTPPTTPKTD Q  K D+KREGRPL EGGRQ  IDF +VDI ELS +VISN+E+FDV\n"+
"Sbjct  116  QGPPTPPTTPKTDAQSNKLDIKREGRPLQEGGRQ-QIDFSNVDIRELSREVISNMESFDV  174\n"+
"\n"+
"Query  292  NEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQ  351\n"+
"            NEFDQYLPPNGHPG    HGQ +   SYG +  +      GH W+SKQQ           \n"+
"Sbjct  175  NEFDQYLPPNGHPG----HGQ-SVAASYGGTGYSIN----GHAWLSKQQQ----------  215\n"+
"\n"+
"Query  352  APPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQS---QRTHIKTEQLSPSHYS  408\n"+
"                                   QQ Q HTL++    P  S   QR H+KTEQLSPSHYS\n"+
"Sbjct  216  -------------------QQQQQQQQQHTLSSPPPPPAISSPEQRAHVKTEQLSPSHYS  256\n"+
"\n"+
"Query  409  EQQQHSPQQI---------------------------------AYSPFNLPHYSPS-YPP  434\n"+
"            +QQQ   Q                                    YSPF++ HY  +  P \n"+
"Sbjct  257  DQQQQQQQPQQQQQHSPQQQQQQQQPQQAQQAQQQVQQQQQLGGYSPFSIQHYGAAVVPA  316\n"+
"\n"+
"Query  435  ITRSQ----------YDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTS  484\n"+
"            I+RSQ          +  +    ++ Y  H+AGQ  GLYS  +YM P+QRP YTPIAD +\n"+
"Sbjct  317  ISRSQYSYADHHHHHHHQSSAAAAAYYSGHSAGQTAGLYSGPSYMGPSQRPSYTPIADAT  376\n"+
"\n"+
"Query  485  GVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            GVPSIPQ HSP  WEQPVYTQLTRP\n"+
"Sbjct  377  GVPSIPQPHSPPSWEQPVYTQLTRP  401\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006752033.1<a name=XP_006752033></a> PREDICTED: POU domain, class 3, transcription factor 2-like [Leptonychotes \n"+
"weddellii]  \n"+
"Length=494\n"+
"\n"+
" Score = 385 bits (988),  Expect = 2e-126, Method: Compositional matrix adjust.\n"+
" Identities = 194/195 (99%), Positives = 194/195 (99%), Gaps = 0/195 (0%)\n"+
"\n"+
"Query  144  RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAI  203\n"+
"            RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAI\n"+
"Sbjct  93   RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAI  152\n"+
"\n"+
"Query  204  FKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGG  263\n"+
"            FKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGG\n"+
"Sbjct  153  FKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGG  212\n"+
"\n"+
"Query  264  RQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISS  323\n"+
"            RQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISS\n"+
"Sbjct  213  RQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISS  272\n"+
"\n"+
"Query  324  TAATPASAGHVWMSK  338\n"+
"            TAATPA AGHVWMSK\n"+
"Sbjct  273  TAATPAGAGHVWMSK  287\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013986160.1<a name=XP_013986160></a> PREDICTED: transcription factor SOX-10 [Salmo salar]\n"+
" XP_013986161.1<a name=XP_013986161></a> PREDICTED: transcription factor SOX-10 [Salmo salar]  \n"+
"Length=494\n"+
"\n"+
" Score = 379 bits (972),  Expect = 5e-124, Method: Compositional matrix adjust.\n"+
" Identities = 241/481 (50%), Positives = 296/481 (62%), Gaps = 81/481 (17%)\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            K E + D+FP+ IREAVSQVL GYDWTLVPMPVRVN  +K+KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  63   KSEVDMDRFPIGIREAVSQVLDGYDWTLVPMPVRVNNGNKSKPHVKRPMNAFMVWAQAAR  122\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLLNES+KRPF+EEAERLR QHKKD+P+YKYQPRRRK\n"+
"Sbjct  123  RKLADQYPHLHNAELSKTLGKLWRLLNESDKRPFIEEAERLRKQHKKDYPEYKYQPRRRK  182\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHIS-PNAIFKALQADSPHSSSG--MSEVHSPGEH--SGQSQGPP  235\n"+
"            + K G         +   S   + +KAL  D   + +G  ++++H    H  +GQ   PP\n"+
"Sbjct  183  NGKLGTNGEGGEGAEGEGSHAQSHYKALHLDVHSTGAGSPLADLHHHHHHHPAGQGHSPP  242\n"+
"\n"+
"Query  236  TPPTTPKTDVQPGK-ADLKRE---------------------GRPLPEGGRQPPIDFRDV  273\n"+
"            TPPTTPKT++Q GK  + KRE                     G     GG+ P IDF  +\n"+
"Sbjct  243  TPPTTPKTELQSGKMTEGKREGGGGSGSSRGGGLGVGAEGASGGHSSAGGK-PHIDFCTM  301\n"+
"\n"+
"Query  274  DIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYT-GSYGISSTAATPASAG  332\n"+
"            DIGE+S DV++NIE FDVNEFDQYLPPNGHPGV    GQ   T  S   S   A  A++G\n"+
"Sbjct  302  DIGEISHDVMANIEPFDVNEFDQYLPPNGHPGV----GQGGATPSSSATSYAYALAAASG  357\n"+
"\n"+
"Query  333  H--VWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPG  390\n"+
"            H   W+SKQ       QQP  +P A  A                                \n"+
"Sbjct  358  HSAAWLSKQHQ----HQQP--SPSASDA--------------------------------  379\n"+
"\n"+
"Query  391  QSQRTHIKTEQLSPSHYSEQQQHSP-QQIAYSPFNLPHYSPSYPPI-TRSQYDYTDHQNS  448\n"+
"               +  IK+E    SHY+E    S    + Y+P +LPHY  ++P + +R+Q++Y +HQ  \n"+
"Sbjct  380  --TKAQIKSESGGGSHYAETSSSSSGTHVTYTPLSLPHYGSAFPSLPSRAQFEYGEHQAP  437\n"+
"\n"+
"Query  449  SSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTR  508\n"+
"              YY+H++ Q  GLYS F+YM P+QRP+YT I D S   S+ Q+HSP HWEQPVYT L+R\n"+
"Sbjct  438  GPYYAHSS-QAPGLYSAFSYMGPSQRPLYTTITDPS---SVAQSHSPTHWEQPVYTTLSR  493\n"+
"\n"+
"Query  509  P  509\n"+
"            P\n"+
"Sbjct  494  P  494\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAW69293.1<a name=AAW69293></a> HMG box transcription factor Sox9b [Carassius auratus x Cyprinus \n"+
"carpio]  \n"+
"Length=416\n"+
"\n"+
" Score = 373 bits (957),  Expect = 7e-123, Method: Compositional matrix adjust.\n"+
" Identities = 225/357 (63%), Positives = 256/357 (72%), Gaps = 27/357 (8%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGS-DTENTRPQENTFPKGEPD  59\n"+
"            MNLLD ++KMT    +G+S APSP++SEDSAGSPC S     DTE  R        G   \n"+
"Sbjct  1    MNLLDRYLKMT----QGVSVAPSPSLSEDSAGSPCSSSGSGSDTETARA-------GIRR  49\n"+
"\n"+
"Query  60   LKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAA  119\n"+
"             +   E++KFPVCIREAVSQVLKGYDW LVPMPVRVNGS+KNKPHVKRPMNAFMVWAQAA\n"+
"Sbjct  50   TELWDEDEKFPVCIREAVSQVLKGYDWPLVPMPVRVNGSTKNKPHVKRPMNAFMVWAQAA  109\n"+
"\n"+
"Query  120  RRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            RRKLADQYPHLHNAELSKTLGKLWRLLNE EKRPFVEEAERLRVQHKKDHPDYKY+PRRR\n"+
"Sbjct  110  RRKLADQYPHLHNAELSKTLGKLWRLLNEGEKRPFVEEAERLRVQHKKDHPDYKYRPRRR  169\n"+
"\n"+
"Query  180  KSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPT  239\n"+
"             SVK+G  E EE  EQT IS  A+F+ALQ   P  SS   EVHSP +HS  SQ PPT PT\n"+
"Sbjct  170  NSVKSGLIETEEG-EQTQISTKAVFRALQQAEPTDSS-KGEVHSPEDHSRHSQDPPTTPT  227\n"+
"\n"+
"Query  240  TPKTDVQ-PGKADLKREGRPLPEGGRQPP---IDFRDVDIGELSSDVISNIETFDVNEFD  295\n"+
"            TP T+ + P K +LKRE       G +PP   IDF  VDIGELSSDVIS+IE FDV EFD\n"+
"Sbjct  228  TPNTERRVPSKEELKRE---RGSHGERPPQHNIDFGVVDIGELSSDVISDIEAFDVKEFD  284\n"+
"\n"+
"Query  296  QYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMS----KQQAPPPPPQQ  348\n"+
"            QYLPP+G+PG  A   +  Y+G    S+    P ++  +  +    +Q +P  P QQ\n"+
"Sbjct  285  QYLPPDGNPG--AAGAKSAYSGHRSASARVHRPLASSSMAKAAQKHQQHSPSSPGQQ  339\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017896058.1<a name=XP_017896058></a> PREDICTED: transcription factor SOX-8 [Capra hircus]  \n"+
"Length=534\n"+
"\n"+
" Score = 372 bits (955),  Expect = 6e-121, Method: Compositional matrix adjust.\n"+
" Identities = 254/519 (49%), Positives = 305/519 (59%), Gaps = 85/519 (16%)\n"+
"\n"+
"Query  21   APSPTMSEDSAGSPC-PSGSGSDTENTRPQENTFP----------------KGEPDLKKE  63\n"+
"            AP   MSE  A  PC PSG+ S   +    ++  P                 G      E\n"+
"Sbjct  71   APMLDMSEARAQPPCSPSGTASSMSHVEDSDSDAPPSPTGSEGLGRAAGAGGGGRGDAAE  130\n"+
"\n"+
"Query  64   SEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAARR  121\n"+
"            + +++FP CIR+AVSQVLKGYDW+LVPMPVR  G    K KPHVKRPMNAFMVWAQAARR\n"+
"Sbjct  131  AADERFPACIRDAVSQVLKGYDWSLVPMPVRGGGGGALKAKPHVKRPMNAFMVWAQAARR  190\n"+
"\n"+
"Query  122  KLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS  181\n"+
"            KLADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS\n"+
"Sbjct  191  KLADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS  250\n"+
"\n"+
"Query  182  VKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTP  241\n"+
"            VK GQ++++   E  H  P  ++K        + +G+ + H   +H+GQ+ GPPTPPTTP\n"+
"Sbjct  251  VKTGQSDSDSGAELGH-HPGGVYK--------TDAGLGDAHHHNDHTGQTHGPPTPPTTP  301\n"+
"\n"+
"Query  242  KTDV-QPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP  300\n"+
"            KTD+   GK +LK EGR L + GRQ  IDF +VDI ELSS+VI N++TFDV+EFDQYLP \n"+
"Sbjct  302  KTDLHHGGKQELKLEGRRLVDSGRQ-NIDFSNVDISELSSEVIGNMDTFDVHEFDQYLPL  360\n"+
"\n"+
"Query  301  NGHPGVPATHGQVTYTGSYGISS---TAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQ  357\n"+
"            NGH  +PA  GQ    GSYG +S   + A    A  VW  K                   \n"+
"Sbjct  361  NGHSALPAEPGQPAAAGSYGGASYSHSGAASIGASPVWAHK-------------------  401\n"+
"\n"+
"Query  358  APPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQ  417\n"+
"              P   A+P +  A PP                   R HIKTEQLSP HY +Q   SP  \n"+
"Sbjct  402  GTPSASASPTE--AGPP-------------------RPHIKTEQLSPGHYGDQSHGSPGH  440\n"+
"\n"+
"Query  418  IAYSPFNL------PHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNP  471\n"+
"              Y  ++          + +    T SQ DYTD Q + SYY    G  +GLY  + Y + \n"+
"Sbjct  441  ADYGSYSAQASVTTAAPAAAASSFTSSQCDYTDLQ-APSYYGPFPGYPSGLYQ-YPYFHS  498\n"+
"\n"+
"Query  472  AQRPMYTPIADTSGVPSIPQTHS-PQHWEQPVYTQLTRP  509\n"+
"             +RP  +P+    G  S+P  HS P +WEQPVYT LTRP\n"+
"Sbjct  499  PRRPYASPLL---GGLSVPPAHSPPSNWEQPVYTTLTRP  534\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012678676.1<a name=XP_012678676></a> PREDICTED: transcription factor SOX-8-like [Clupea harengus] \n"+
" \n"+
"Length=473\n"+
"\n"+
" Score = 368 bits (944),  Expect = 4e-120, Method: Compositional matrix adjust.\n"+
" Identities = 249/531 (47%), Positives = 310/531 (58%), Gaps = 86/531 (16%)\n"+
"\n"+
"Query  7    FMKMTDEQEKGLSGAP------SPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"              KM +E+EKGL   P      + +MS+    S  PS S ++++   P +    +GE  +\n"+
"Sbjct  1    MFKMNEEREKGLGEQPCSPSGTASSMSQVDLDSDAPS-SPTESDGQGPVQQQLARGEK-V  58\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"                E+++FPVCIR+AVSQVLKGYDW+L+PMP+R + S K+KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  59   GGGDEDERFPVCIRDAVSQVLKGYDWSLIPMPMRGSRSLKDKPHVKRPMNAFMVWAQAAR  118\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLL+E+EKRPFVEEA+RLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  119  RKLADQYPHLHNAELSKTLGKLWRLLSENEKRPFVEEADRLRVQHKKDHPDYKYQPRRRK  178\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKA-LQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPT  239\n"+
"            S+K GQ++ +  TE  H   + ++K  +   S H   G+  +H P +HSGQ  GPPTPPT\n"+
"Sbjct  179  SLKPGQSDPDAGTELDHPHSDQLYKGEVGVSSLH--LGIGSLHHPHDHSGQPHGPPTPPT  236\n"+
"\n"+
"Query  240  TPKTD-VQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYL  298\n"+
"            TPK D    GK D K EGR   +GGRQ  IDF +VDI ELS+DVISN+ETFDV+EFDQYL\n"+
"Sbjct  237  TPKADPSHGGKHDFKLEGRRGLDGGRQ-NIDFSNVDISELSTDVISNMETFDVHEFDQYL  295\n"+
"\n"+
"Query  299  PPNGHPGVPAT---HGQ-VTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPP  354\n"+
"            PPNG   V +    HGQ     GS+G      + A+ GH          P          \n"+
"Sbjct  296  PPNGTHAVLSDHQGHGQSAAGAGSFGSFGHGHSGAAWGH--------KGPGSAGCVSGSG  347\n"+
"\n"+
"Query  355  APQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQ---Q  411\n"+
"            A QA PQ                                   IKTEQLSP HY+EQ    \n"+
"Sbjct  348  AAQARPQ-----------------------------------IKTEQLSPRHYAEQSSTS  372\n"+
"\n"+
"Query  412  QHSPQQIAYSPFNLPHYS-------------PSYPPITRSQYDYTDHQNSSSYYSHAAGQ  458\n"+
"              SPQQ      NL  Y               S   +  S  DYTD Q +++Y++   G \n"+
"Sbjct  373  SSSPQQ------NLGSYGTQTCTSSTTSSSSSSSSSLAASSGDYTDLQ-TANYFTAYPGY  425\n"+
"\n"+
"Query  459  GTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"              G+Y  + Y + ++RP  + I ++  +P  P      +WEQPVYT LTRP\n"+
"Sbjct  426  PAGIYQ-YPYFHSSRRPYASSILNSLSMP--PAHGGASNWEQPVYTTLTRP  473\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007901694.1<a name=XP_007901694></a> PREDICTED: transcription factor SOX-8 [Callorhinchus milii]  \n"+
"\n"+
"Length=426\n"+
"\n"+
" Score = 364 bits (935),  Expect = 2e-119, Method: Compositional matrix adjust.\n"+
" Identities = 230/416 (55%), Positives = 276/416 (66%), Gaps = 56/416 (13%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV\n"+
"Sbjct  57   HIKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  116\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQ-ADSPHSSSGMSEVH  222\n"+
"            QHKKDHPDYKYQPRRRKSVKNGQAE+E + +Q H+S + +FK++  +D+   +  +SE H\n"+
"Sbjct  117  QHKKDHPDYKYQPRRRKSVKNGQAESEASPDQGHVSGSQLFKSIHPSDNLLGAGVISEGH  176\n"+
"\n"+
"Query  223  SPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDV  282\n"+
"             P EH+G +QGPPTPPTTPKTD+   K +LKREGRPL E GRQ  IDF +VDI ELSS+V\n"+
"Sbjct  177  HPSEHTGHNQGPPTPPTTPKTDLHTAKQELKREGRPLVENGRQ-NIDFSNVDISELSSEV  235\n"+
"\n"+
"Query  283  ISNIETFDVNEFDQYLPPNGHPGVPATHGQV---------TYTGSYGISSTAATPASAGH  333\n"+
"            ISNIETFDV+EFDQYLP NGH G+P  H              TGSY + S +A  A    \n"+
"Sbjct  236  ISNIETFDVHEFDQYLPLNGHGGLPGDHAHAHPHSHGHLQNSTGSYSV-SYSANGAGTQV  294\n"+
"\n"+
"Query  334  VWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQ  393\n"+
"            VW  K  +                                     + + +++SSEPGQ Q\n"+
"Sbjct  295  VWNHKSNS------------------------------------SSSSSSSVSSEPGQ-Q  317\n"+
"\n"+
"Query  394  RTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYS  453\n"+
"            R HIKTEQLSPSHYSE QQH PQ   YS F+    S +    +  Q DY+D Q  ++YY+\n"+
"Sbjct  318  RPHIKTEQLSPSHYSE-QQHGPQS-DYSSFSNQSCSSATAVFSGPQCDYSDIQ-GTNYYN  374\n"+
"\n"+
"Query  454  HAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"               G  +G+Y  + Y +P++R   +PI +     SIP +HSP +WEQPVYT LTRP\n"+
"Sbjct  375  PYPGYPSGIYQ-YPYFHPSRRSYASPILNPL---SIPPSHSPTNWEQPVYTTLTRP  426\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005444177.1<a name=XP_005444177></a> PREDICTED: transcription factor SOX-8, partial [Falco cherrug] \n"+
" \n"+
"Length=369\n"+
"\n"+
" Score = 362 bits (929),  Expect = 2e-119, Method: Compositional matrix adjust.\n"+
" Identities = 211/364 (58%), Positives = 245/364 (67%), Gaps = 49/364 (13%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLAD  125\n"+
"            +++FP CIR+AVSQVLKGYDW+LVPMPVR NGS K KPHVKRPMNAFMVWAQAARRKLAD\n"+
"Sbjct  39   DERFPACIRDAVSQVLKGYDWSLVPMPVRGNGSLKAKPHVKRPMNAFMVWAQAARRKLAD  98\n"+
"\n"+
"Query  126  QYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNG  185\n"+
"            QYPHLHNAELSKTLGKLWRLL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK G\n"+
"Sbjct  99   QYPHLHNAELSKTLGKLWRLLSENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKAG  158\n"+
"\n"+
"Query  186  QAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDV  245\n"+
"            Q++++   E +H +   I+K   ADS     GM++ H   +H+GQ+ GPPTPPTTPKTD+\n"+
"Sbjct  159  QSDSDSGAELSHHAGTQIYK---ADS--GLGGMADSHHHSDHTGQTHGPPTPPTTPKTDL  213\n"+
"\n"+
"Query  246  QPG-KADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHP  304\n"+
"              G K +LK EGR L E GRQ  IDF +VDI ELSS+VI+N+ETFDV+EFDQYLP NGH \n"+
"Sbjct  214  HHGSKQELKHEGRRLVESGRQ-NIDFSNVDISELSSEVINNMETFDVHEFDQYLPLNGHA  272\n"+
"\n"+
"Query  305  GVPATHGQVTYTGSYGISSTAATPASAG--HVWMSKQQAPPPPPQQPPQAPPAPQAPPQP  362\n"+
"             +PA HG     GSYG S + +   + G   VW  K  A                     \n"+
"Sbjct  273  AMPADHGPSAAAGSYGASYSHSATGTGGTNQVWTHKSPASA-------------------  313\n"+
"\n"+
"Query  363  QAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSP  422\n"+
"                                +  S++ GQ QR HIKTEQLSPSHYS+Q   SP    Y  \n"+
"Sbjct  314  --------------------SPSSADSGQ-QRPHIKTEQLSPSHYSDQSHGSPAHSDYGS  352\n"+
"\n"+
"Query  423  FNLP  426\n"+
"               P\n"+
"Sbjct  353  HKGP  356\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006061803.1<a name=XP_006061803></a> PREDICTED: transcription factor SOX-8 [Bubalus bubalis]  \n"+
"Length=566\n"+
"\n"+
" Score = 368 bits (944),  Expect = 8e-119, Method: Compositional matrix adjust.\n"+
" Identities = 238/457 (52%), Positives = 285/457 (62%), Gaps = 68/457 (15%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAARRKL  123\n"+
"            +++FP CIR+AVSQVLKGYDW+LVPMPVR  G    K KPHVKRPMNAFMVWAQAARRKL\n"+
"Sbjct  165  DERFPACIRDAVSQVLKGYDWSLVPMPVRGGGGGALKAKPHVKRPMNAFMVWAQAARRKL  224\n"+
"\n"+
"Query  124  ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK\n"+
"Sbjct  225  ADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  284\n"+
"\n"+
"Query  184  NGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKT  243\n"+
"             GQ++++   E  H  P  ++K        + +G+ + H   +H+GQ+ GPPTPPTTPKT\n"+
"Sbjct  285  TGQSDSDSGAELGH-HPGGMYK--------TDAGLGDAHHHSDHTGQTHGPPTPPTTPKT  335\n"+
"\n"+
"Query  244  DV-QPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNG  302\n"+
"            D+   GK +LK EGR L + GRQ  IDF +VDI ELSS+VI N++TFDV+EFDQYLP NG\n"+
"Sbjct  336  DLHHGGKQELKLEGRRLVDSGRQ-NIDFSNVDISELSSEVIGNMDTFDVHEFDQYLPLNG  394\n"+
"\n"+
"Query  303  HPGVPATHGQVTYTGSYGISS---TAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAP  359\n"+
"            H  +PA  GQ    GSYG +S   + A    A  VW  K                     \n"+
"Sbjct  395  HSALPAEPGQPAAAGSYGGASYSHSGAAGIGASPVWAHK-------------------GT  435\n"+
"\n"+
"Query  360  PQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIA  419\n"+
"            P   A+P +  A PP                   R HIKTEQLSP HY +Q   SP    \n"+
"Sbjct  436  PSASASPTE--AGPP-------------------RPHIKTEQLSPGHYGDQSHGSPGHAD  474\n"+
"\n"+
"Query  420  YSPFNL------PHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQ  473\n"+
"            +  ++          + +    T SQ DYTD Q + SYY    G  +GLY  + Y +  +\n"+
"Sbjct  475  FGSYSAQASVTTAAPAAAASSFTSSQCDYTDLQ-APSYYGPFPGYPSGLYQ-YPYFHSPR  532\n"+
"\n"+
"Query  474  RPMYTPIADTSGVPSIPQTHS-PQHWEQPVYTQLTRP  509\n"+
"            RP  +P+    G  S+P  HS P +WEQPVYT LTRP\n"+
"Sbjct  533  RPYASPLL---GGLSVPPAHSPPSNWEQPVYTTLTRP  566\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015346099.1<a name=XP_015346099></a> PREDICTED: transcription factor SOX-8 [Marmota marmota marmota] \n"+
" \n"+
"Length=414\n"+
"\n"+
" Score = 361 bits (927),  Expect = 2e-118, Method: Compositional matrix adjust.\n"+
" Identities = 239/460 (52%), Positives = 291/460 (63%), Gaps = 70/460 (15%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVN--GSSKNKPHVKRPMNAFMVWAQAARRKL  123\n"+
"            +++FP CIR+AVSQVLKGYDW+LVPMPVR    G+ K KPHVKRPMNAFMVWAQAARRKL\n"+
"Sbjct  9    DERFPACIRDAVSQVLKGYDWSLVPMPVRGGNGGALKAKPHVKRPMNAFMVWAQAARRKL  68\n"+
"\n"+
"Query  124  ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ADQYPHLHNAELSKTLGKLWRLL ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS+K\n"+
"Sbjct  69   ADQYPHLHNAELSKTLGKLWRLLTESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSMK  128\n"+
"\n"+
"Query  184  NGQAEAEEATEQTHISPNAIFKALQADSPHSSSGM-SEVHSPGEHSGQSQGPPTPPTTPK  242\n"+
"             GQ++++   E  H     ++KA         +G+  + H  G+H+GQ+ GPPTPPTTPK\n"+
"Sbjct  129  TGQSDSDSGAELGHHPGGTMYKA--------DAGLHGDTHHHGDHTGQTHGPPTPPTTPK  180\n"+
"\n"+
"Query  243  TDVQ----PGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYL  298\n"+
"            TD+      GK +LK EGR L + GRQ  IDF +VDI ELSS+VISN++TFDV+EFDQYL\n"+
"Sbjct  181  TDLHHPAGGGKQELKPEGRRLVDSGRQ-NIDFSNVDISELSSEVISNMDTFDVHEFDQYL  239\n"+
"\n"+
"Query  299  PPNGHPGVPATHGQVTYTGSYGISSTAATPASAGH--VWMSKQQAPPPPPQQPPQAPPAP  356\n"+
"            P NGH  +PA   Q    GSYG +S + + AS G   VW  K                AP\n"+
"Sbjct  240  PLNGHSTLPAEPSQAAAAGSYGGTSYSHSGASVGVSPVWAHKG---------------AP  284\n"+
"\n"+
"Query  357  QAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQ  416\n"+
"             A   P  A P +P                         HIKTEQLSP HY +Q   SP \n"+
"Sbjct  285  SASASPTEAGPSRP-------------------------HIKTEQLSPGHYGDQPHGSPG  319\n"+
"\n"+
"Query  417  QIAYSPFNL------PHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMN  470\n"+
"            +  YS ++          + +      +Q DYTD Q +S+YYS  AG    LY  + Y +\n"+
"Sbjct  320  RSDYSSYSAQASVTSAAPATAASSFASAQCDYTDLQ-ASNYYSPYAGYAPSLYQ-YPYFH  377\n"+
"\n"+
"Query  471  PAQRPMYTPIADTSGVPSIPQTHSPQ-HWEQPVYTQLTRP  509\n"+
"             ++RP  +P+ +  G+ S+P  HSP  +W+QPVYT LTRP\n"+
"Sbjct  378  SSRRPYASPLLN--GL-SVPPAHSPSGNWDQPVYTTLTRP  414\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010946986.1<a name=XP_010946986></a> PREDICTED: transcription factor SOX-9-like, partial [Camelus \n"+
"bactrianus]  \n"+
"Length=228\n"+
"\n"+
" Score = 354 bits (908),  Expect = 3e-118, Method: Compositional matrix adjust.\n"+
" Identities = 172/174 (99%), Positives = 173/174 (99%), Gaps = 0/174 (0%)\n"+
"\n"+
"Query  144  RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAI  203\n"+
"            RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA+EQTHISPNAI\n"+
"Sbjct  55   RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEASEQTHISPNAI  114\n"+
"\n"+
"Query  204  FKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGG  263\n"+
"            FKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPL EGG\n"+
"Sbjct  115  FKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLSEGG  174\n"+
"\n"+
"Query  264  RQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTG  317\n"+
"            RQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTG\n"+
"Sbjct  175  RQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTG  228\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">DAA15743.1<a name=DAA15743></a> TPA: SRY (sex determining region Y)-box 8-like [Bos taurus]  \n"+
"\n"+
"Length=747\n"+
"\n"+
" Score = 371 bits (952),  Expect = 8e-118, Method: Compositional matrix adjust.\n"+
" Identities = 239/457 (52%), Positives = 286/457 (63%), Gaps = 68/457 (15%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAARRKL  123\n"+
"            +++FP CIR+AVSQVLKGYDW+LVPMPVR  G    K KPHVKRPMNAFMVWAQAARRKL\n"+
"Sbjct  346  DERFPACIRDAVSQVLKGYDWSLVPMPVRGGGGGALKAKPHVKRPMNAFMVWAQAARRKL  405\n"+
"\n"+
"Query  124  ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK\n"+
"Sbjct  406  ADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  465\n"+
"\n"+
"Query  184  NGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKT  243\n"+
"             GQ++++   E  H  P +++K        + +G+ + H   +H+GQ+ GPPTPPTTPKT\n"+
"Sbjct  466  TGQSDSDSGAELGH-HPGSMYK--------TDAGLGDAHHHSDHTGQTHGPPTPPTTPKT  516\n"+
"\n"+
"Query  244  DV-QPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNG  302\n"+
"            D+   GK +LK EGR L + GRQ  IDF +VDI ELSS+VI N++TFDV+EFDQYLP NG\n"+
"Sbjct  517  DLHHGGKQELKLEGRRLVDSGRQ-NIDFSNVDISELSSEVIGNMDTFDVHEFDQYLPLNG  575\n"+
"\n"+
"Query  303  HPGVPATHGQVTYTGSYGISS---TAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAP  359\n"+
"            H  +PA  GQ    GSYG +S   + A    A  VW  K                     \n"+
"Sbjct  576  HSALPAEPGQPAAAGSYGGTSYSHSGAASIGASPVWAHK-------------------GT  616\n"+
"\n"+
"Query  360  PQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIA  419\n"+
"            P   A+P +  A PP                   R HIKTEQLSP HY +Q   SP    \n"+
"Sbjct  617  PSASASPTE--AGPP-------------------RPHIKTEQLSPGHYGDQSHGSPGHAD  655\n"+
"\n"+
"Query  420  YSPFNL------PHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQ  473\n"+
"            Y  ++          + +    T SQ DYTD Q + SYY    G  +GLY  + Y +  +\n"+
"Sbjct  656  YGSYSAQASVTTAAPAAAASSFTSSQCDYTDLQ-APSYYGPFPGYPSGLYQ-YPYFHSPR  713\n"+
"\n"+
"Query  474  RPMYTPIADTSGVPSIPQTHS-PQHWEQPVYTQLTRP  509\n"+
"            RP  +P+    G  S+P  HS P +WEQPVYT LTRP\n"+
"Sbjct  714  RPYASPLL---GGLSVPPAHSPPSNWEQPVYTTLTRP  747\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_008568803.1<a name=XP_008568803></a> PREDICTED: transcription factor SOX-8 [Galeopterus variegatus] \n"+
" \n"+
"Length=1001\n"+
"\n"+
" Score = 376 bits (966),  Expect = 2e-117, Method: Compositional matrix adjust.\n"+
" Identities = 243/456 (53%), Positives = 294/456 (64%), Gaps = 69/456 (15%)\n"+
"\n"+
"Query  66    EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAARRKL  123\n"+
"             +++FP CIR+AVSQVLKGYDW+LVPMPVR  G    K KPHVKRPMNAFMVWAQAARRKL\n"+
"Sbjct  603   DERFPACIRDAVSQVLKGYDWSLVPMPVRGGGGGALKAKPHVKRPMNAFMVWAQAARRKL  662\n"+
"\n"+
"Query  124   ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"             ADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK\n"+
"Sbjct  663   ADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  722\n"+
"\n"+
"Query  184   NGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKT  243\n"+
"              GQ++++   E  H   +A++KA          G+S+ H  G+H+GQ+ GPPTPPTTPKT\n"+
"Sbjct  723   TGQSDSDSGAELGHHPSSAMYKA--------DVGLSDTHHHGDHTGQTHGPPTPPTTPKT  774\n"+
"\n"+
"Query  244   DVQ---PGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP  300\n"+
"             D+     GK +LK EGR L + GRQ  IDF +VDI ELSS+VISN++TFDV+EFDQYLP \n"+
"Sbjct  775   DLHHAGGGKPELKLEGRRLVDSGRQ-NIDFSNVDISELSSEVISNMDTFDVHEFDQYLPL  833\n"+
"\n"+
"Query  301   NGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPP  360\n"+
"             NGH  +PA  GQ   T SYG +S + + AS   VW  K                AP A  \n"+
"Sbjct  834   NGHSAMPAEPGQAA-TVSYGGTSYSHSGASP--VWAHKA---------------APSASA  875\n"+
"\n"+
"Query  361   QPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAY  420\n"+
"              P  A P +P                         HIKTEQLSPSHY +Q   SP +  Y\n"+
"Sbjct  876   SPTEAGPPRP-------------------------HIKTEQLSPSHYGDQPHGSPGRSDY  910\n"+
"\n"+
"Query  421   SPFNL-PHYSPSYP-----PITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQR  474\n"+
"               ++     +P+ P         SQ DYTD Q +S+YYS   G  + LY  + Y + ++R\n"+
"Sbjct  911   GSYSAQASVTPAGPAGAASSFASSQCDYTDLQ-ASNYYSPYPGYPSSLYQ-YPYFHSSRR  968\n"+
"\n"+
"Query  475   PMYTPIADTSGVPSIPQTHS-PQHWEQPVYTQLTRP  509\n"+
"             P  +P+ ++    S+P  HS P +W+QPVYT LTRP\n"+
"Sbjct  969   PYASPLINSL---SLPPAHSPPSNWDQPVYTTLTRP  1001\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010897926.2<a name=XP_010897926></a> PREDICTED: transcription factor Sox-8 isoform X1 [Esox lucius] \n"+
" \n"+
"Length=470\n"+
"\n"+
" Score = 358 bits (919),  Expect = 2e-116, Method: Compositional matrix adjust.\n"+
" Identities = 237/461 (51%), Positives = 291/461 (63%), Gaps = 66/461 (14%)\n"+
"\n"+
"Query  65   EEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLA  124\n"+
"            ++D+FP CIR+AVSQVLKGYDW+LVPMPVR NGS KNKPHVKRPMNAFMVWAQAARRKLA\n"+
"Sbjct  60   DDDRFPACIRDAVSQVLKGYDWSLVPMPVRGNGSLKNKPHVKRPMNAFMVWAQAARRKLA  119\n"+
"\n"+
"Query  125  DQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"             +YPHLHNAELSKTL KLWRLL+E+EKRPFVEEAERLRVQHK+DHPDYKYQPRRRKSVK \n"+
"Sbjct  120  TKYPHLHNAELSKTLEKLWRLLSENEKRPFVEEAERLRVQHKRDHPDYKYQPRRRKSVKP  179\n"+
"\n"+
"Query  185  GQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTD  244\n"+
"            GQ++++   E +H     ++K      P    G+++ H   EH+GQ+ GPPTPPTTPKTD\n"+
"Sbjct  180  GQSDSDSGAELSH----QMYKP----EPGMLPGIADGHHHTEHAGQTHGPPTPPTTPKTD  231\n"+
"\n"+
"Query  245  V-QPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGH  303\n"+
"            +   GK DLK EGR L +GGRQ  IDF +VDI ELS+DVISN+E FDV+EFDQYLP NGH\n"+
"Sbjct  232  LHHGGKQDLKHEGRRLLDGGRQ-NIDFSNVDISELSTDVISNMEAFDVHEFDQYLPLNGH  290\n"+
"\n"+
"Query  304  PGVPAT-----HGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQA  358\n"+
"                       HG    +G+   +S+ + P   G VW  K  A             +  +\n"+
"Sbjct  291  ASTAGMDHHGHHGPNPASGATSYTSSYSHPTVNGAVWSRKSAA------------MSASS  338\n"+
"\n"+
"Query  359  PPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQI  418\n"+
"            P   +A PPQ                         R HIKTEQLSPSHY  Q  HS    \n"+
"Sbjct  339  PASNEALPPQ------------------------HRAHIKTEQLSPSHYGSQHSHSSPSH  374\n"+
"\n"+
"Query  419  -----AYSPFNLPHYSPSYPP--ITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNP  471\n"+
"                 +Y+       SP+      + SQ DYTD Q SS+YY+  +G  + LY  + Y + \n"+
"Sbjct  375  PDYSHSYTAQTCVTSSPTAAAGSFSGSQCDYTDLQ-SSNYYNPYSGYPSSLYQ-YPYFHS  432\n"+
"\n"+
"Query  472  AQRPMY-TPIADTSGVPSIPQTHSP--QHWEQPVYTQLTRP  509\n"+
"            ++R  + +PI ++    S+P THSP    W+QPVYT L+RP\n"+
"Sbjct  433  SRRAYHGSPILNS---LSMPPTHSPTTSSWDQPVYTTLSRP  470\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_016379878.1<a name=XP_016379878></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-8 [Sinocyclocheilus \n"+
"rhinocerous]  \n"+
"Length=434\n"+
"\n"+
" Score = 357 bits (915),  Expect = 2e-116, Method: Compositional matrix adjust.\n"+
" Identities = 239/454 (53%), Positives = 278/454 (61%), Gaps = 68/454 (15%)\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            K E E+D+FPVCIR+AVSQVLKGYDW+LVPMP R +G+ K+KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  44   KLEREDDRFPVCIRDAVSQVLKGYDWSLVPMPARGSGAIKSKPHVKRPMNAFMVWAQAAR  103\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLL E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  104  RKLADQYPHLHNAELSKTLGKLWRLLTENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  163\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGE--HSGQSQGPPTPP  238\n"+
"            SVK GQ        + ++   ++ K +  +          + +P     SGQ  GPPTPP\n"+
"Sbjct  164  SVKPGQRLQRGG--KFNLDRWSLKKTVDGEXKTLCDAYKCI-TPASLLSSGQPHGPPTPP  220\n"+
"\n"+
"Query  239  TTPKTDV-QPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQY  297\n"+
"            TTPKTD    GK D K EGR L +G RQ  IDF +VDI ELS+DVISN+E FDV+EFDQY\n"+
"Sbjct  221  TTPKTDFHHGGKPDPKHEGRRLLDGTRQ-NIDFSNVDISELSTDVISNMEAFDVHEFDQY  279\n"+
"\n"+
"Query  298  LPPNGHPG-VPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAP  356\n"+
"            LPP+GH G  P   G  +Y   Y      + PAS G  W  K               P  \n"+
"Sbjct  280  LPPSGHAGAAPDGQGASSYASPY------SHPASCGASWSRKG--------------PVA  319\n"+
"\n"+
"Query  357  QAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQ  416\n"+
"             +PP                         +SE  Q  R  IKTEQLSPSHYSE   HSP+\n"+
"Sbjct  320  SSPPG------------------------TSEASQ-HRARIKTEQLSPSHYSE---HSPE  351\n"+
"\n"+
"Query  417  QIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPM  476\n"+
"               YS         S         DYTD Q SS YYS  AG  +GLY  + Y + ++RP \n"+
"Sbjct  352  YGVYSA------HGSSAASASFASDYTDLQ-SSGYYSPYAGYPSGLYQ-YPYFHSSRRPY  403\n"+
"\n"+
"Query  477  YTPIADTSGVPSIPQTHSPQ-HWEQPVYTQLTRP  509\n"+
"             + I +  G+ SIP +HSP   W+QPVYT L+RP\n"+
"Sbjct  404  GSNILN--GL-SIPPSHSPSASWDQPVYTTLSRP  434\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAB71726.1<a name=BAB71726></a> Sry-related transcription factor Sox9, partial [Rattus norvegicus] \n"+
" \n"+
"Length=164\n"+
"\n"+
" Score = 346 bits (887),  Expect = 5e-116, Method: Compositional matrix adjust.\n"+
" Identities = 163/164 (99%), Positives = 164/164 (100%), Gaps = 0/164 (0%)\n"+
"\n"+
"Query  16   KGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIRE  75\n"+
"            KGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIRE\n"+
"Sbjct  1    KGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIRE  60\n"+
"\n"+
"Query  76   AVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAEL  135\n"+
"            AVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAEL\n"+
"Sbjct  61   AVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAEL  120\n"+
"\n"+
"Query  136  SKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            SKTLGKLWRLLNESEKRPFVEEAERLRVQH+KDHPDYKYQPRRR\n"+
"Sbjct  121  SKTLGKLWRLLNESEKRPFVEEAERLRVQHRKDHPDYKYQPRRR  164\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAB49282.1<a name=AAB49282></a> transcription factor Sox-M, partial [Mus musculus]  \n"+
"Length=533\n"+
"\n"+
" Score = 359 bits (922),  Expect = 6e-116, Method: Compositional matrix adjust.\n"+
" Identities = 214/380 (56%), Positives = 246/380 (65%), Gaps = 55/380 (14%)\n"+
"\n"+
"Query  63   ESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRK  122\n"+
"            E+++DKFPVCIREAVSQVL GYDWTLVPMPVRVNG+SK+KPHVKRPMNAFMVWAQAARRK\n"+
"Sbjct  156  EADDDKFPVCIREAVSQVLSGYDWTLVPMPVRVNGASKSKPHVKRPMNAFMVWAQAARRK  215\n"+
"\n"+
"Query  123  LADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSV  182\n"+
"            LADQYPHLHNAELSKTLGKLWRLLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+ \n"+
"Sbjct  216  LADQYPHLHNAELSKTLGKLWRLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKNG  275\n"+
"\n"+
"Query  183  KNGQAEAE----EATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEH-SGQSQGPPTP  237\n"+
"            K  Q EAE    EA +    +  A +K+   D  H   G        EH SGQS GPPTP\n"+
"Sbjct  276  KAAQGEAECPGGEAEQGGAAAIQAHYKSAHLDHRHPEEGSPMSDGNPEHPSGQSHGPPTP  335\n"+
"\n"+
"Query  238  PTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQY  297\n"+
"            PTTPKT++Q GKAD KR+GR L EGG+ P IDF +VDIGE+S +V+SN+ETFDV E DQY\n"+
"Sbjct  336  PTTPKTELQSGKADPKRDGRSLGEGGK-PHIDFGNVDIGEISHEVMSNMETFDVTELDQY  394\n"+
"\n"+
"Query  298  LPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQ  357\n"+
"            LPPNGHPG    H        YG+ S  A  AS    W+SK              PP   \n"+
"Sbjct  395  LPPNGHPG----HVGSYSAAGYGLGSALAV-ASGHSAWISK--------------PPGVA  435\n"+
"\n"+
"Query  358  APPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPS---HYSEQQQHS  414\n"+
"             P                           S PG   +  ++TE   P    HY++Q   S\n"+
"Sbjct  436  LP-------------------------TVSPPGVDAKAQVETETTGPQGPPHYTDQP--S  468\n"+
"\n"+
"Query  415  PQQIAYSPFNLPHYSPSYPP  434\n"+
"              QIAY+  +LPHY  + PP\n"+
"Sbjct  469  TSQIAYTSLSLPHYGSASPP  488\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011602318.1<a name=XP_011602318></a> PREDICTED: transcription factor SOX-9-like [Takifugu rubripes] \n"+
" \n"+
"Length=294\n"+
"\n"+
" Score = 342 bits (878),  Expect = 9e-113, Method: Compositional matrix adjust.\n"+
" Identities = 162/183 (89%), Positives = 171/183 (93%), Gaps = 1/183 (1%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDP++KMT+EQEK  S APSP+MSEDSAGSPCPSGSGSDTENTRP +N    G PD \n"+
"Sbjct  1    MNLLDPYLKMTEEQEKCHSDAPSPSMSEDSAGSPCPSGSGSDTENTRPSDNHLLLG-PDY  59\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            KKE+EE+KFPVCIR+AVSQVLKGYDWTLVPMPVRVNGS+KNKPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  60   KKENEEEKFPVCIRDAVSQVLKGYDWTLVPMPVRVNGSNKNKPHVKRPMNAFMVWAQAAR  119\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLLNE EKRPFVEEAERLRVQH KDHPDYKYQPRRRK\n"+
"Sbjct  120  RKLADQYPHLHNAELSKTLGKLWRLLNEVEKRPFVEEAERLRVQHNKDHPDYKYQPRRRK  179\n"+
"\n"+
"Query  181  SVK  183\n"+
"            SVK\n"+
"Sbjct  180  SVK  182\n"+
"\n"+
"\n"+
" Score = 172 bits (437),  Expect = 5e-47, Method: Compositional matrix adjust.\n"+
" Identities = 88/120 (73%), Positives = 103/120 (86%), Gaps = 5/120 (4%)\n"+
"\n"+
"Query  393  QRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYS-PSYPPITRSQYDYTDHQN-SSS  450\n"+
"            +R  +KT QLSPSHYSEQQ  SPQ + Y  FNL HYS  SYP +TR+QYDY+DHQ  ++S\n"+
"Sbjct  177  RRKSVKT-QLSPSHYSEQQG-SPQHVTYGSFNLQHYSTSSYPSMTRAQYDYSDHQGGANS  234\n"+
"\n"+
"Query  451  YYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWE-QPVYTQLTRP  509\n"+
"            YYSHAAGQG+GLYSTF+YMNP+QRPMYTPIAD +GVPS+PQTHSPQHWE QP+YTQL+RP\n"+
"Sbjct  235  YYSHAAGQGSGLYSTFSYMNPSQRPMYTPIADNAGVPSVPQTHSPQHWEQQPIYTQLSRP  294\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006637076.2<a name=XP_006637076></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-8 [Lepisosteus \n"+
"oculatus]  \n"+
"Length=437\n"+
"\n"+
" Score = 347 bits (891),  Expect = 1e-112, Method: Compositional matrix adjust.\n"+
" Identities = 200/344 (58%), Positives = 244/344 (71%), Gaps = 34/344 (10%)\n"+
"\n"+
"Query  7    FMKMTDEQEKGLSGAP------SPTMSEDSAGSPCP-SGSGSDTENTRPQENTFPKGEPD  59\n"+
"             +KMT+E +K L+  P      + +MS++ + S  P S +GSD   ++ +     +GE  \n"+
"Sbjct  1    MLKMTEEHDKSLADPPCSPAGTTSSMSQEDSDSDAPLSPTGSDGPGSQHRLGKKLEGE--  58\n"+
"\n"+
"Query  60   LKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAA  119\n"+
"                 E+++FP CIR+AVSQVLKGYDW+LVPMPVR +GS KNKPHVKRPMNAFMVWAQAA\n"+
"Sbjct  59   -----EDERFPACIRDAVSQVLKGYDWSLVPMPVRGSGSLKNKPHVKRPMNAFMVWAQAA  113\n"+
"\n"+
"Query  120  RRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            RRKLADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR\n"+
"Sbjct  114  RRKLADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  173\n"+
"\n"+
"Query  180  KSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPT  239\n"+
"            KSVK GQ++++   E +H   + I+K+          G+++ H   +H+GQ  GPPTPPT\n"+
"Sbjct  174  KSVKTGQSDSDSGAELSHHPSSQIYKS------EPLGGLADGHHHSDHAGQPHGPPTPPT  227\n"+
"\n"+
"Query  240  TPKTDV-QPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYL  298\n"+
"            TPKTD+ Q  K DLK EGR L + GRQ  IDF +VDI ELS+DVI NIE FDV+EFDQYL\n"+
"Sbjct  228  TPKTDLHQVSKQDLKHEGRRLLDSGRQ-NIDFSNVDITELSTDVIGNIEAFDVHEFDQYL  286\n"+
"\n"+
"Query  299  PPNGHPG--------VPATHGQ---VTYTGSYGISSTAATPASA  331\n"+
"            PPNGH             +HG      Y+ SYG  ++AA+P  A\n"+
"Sbjct  287  PPNGHATEQLSPSHYSEHSHGSPAPAEYS-SYGAQTSAASPTVA  329\n"+
"\n"+
"\n"+
" Score = 52.0 bits (123),  Expect = 4e-04, Method: Compositional matrix adjust.\n"+
" Identities = 42/101 (42%), Positives = 58/101 (57%), Gaps = 10/101 (10%)\n"+
"\n"+
"Query  399  TEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPI----TRSQYDYTDHQNSSSYYSH  454\n"+
"            TEQLSPSHYSE    SP    YS +     S + P +    + SQ DYTD Q SS+YY+ \n"+
"Sbjct  293  TEQLSPSHYSEHSHGSPAPAEYSSYGA-QTSAASPTVATSFSSSQCDYTDLQ-SSNYYNP  350\n"+
"\n"+
"Query  455  AAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP  495\n"+
"             +G  + LY  + Y + ++RP  TP+ ++    SIP +HSP\n"+
"Sbjct  351  YSGYPSSLY-QYPYFHSSRRPYATPLLNSL---SIPPSHSP  387\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">CCP19140.1<a name=CCP19140></a> SRY-related box 8, partial [Latimeria menadoensis]  \n"+
"Length=244\n"+
"\n"+
" Score = 340 bits (873),  Expect = 1e-112, Method: Compositional matrix adjust.\n"+
" Identities = 178/246 (72%), Positives = 202/246 (82%), Gaps = 7/246 (3%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLAD  125\n"+
"            +D+FP CIR+AVSQVLKGYDW+LVPMPVR NGS K KPHVKRPMNAFMVWAQAARRKLAD\n"+
"Sbjct  5    DDRFPACIRDAVSQVLKGYDWSLVPMPVRGNGSLKAKPHVKRPMNAFMVWAQAARRKLAD  64\n"+
"\n"+
"Query  126  QYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNG  185\n"+
"            QYPHLHNAELSKTLGKLWRLL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK G\n"+
"Sbjct  65   QYPHLHNAELSKTLGKLWRLLSENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKAG  124\n"+
"\n"+
"Query  186  QAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDV  245\n"+
"            Q++++   E +H   + ++K     S    SGM E H   EH+GQ+ GPPTPPTTPKTD+\n"+
"Sbjct  125  QSDSDSGAELSHHPGSQLYK-----SDTGLSGMGEAHHHSEHTGQTHGPPTPPTTPKTDL  179\n"+
"\n"+
"Query  246  QPG-KADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHP  304\n"+
"              G K DLK EGR L + GRQ  IDF +VDI ELSS+VI+N+ETFDV+EFDQYLP NGH \n"+
"Sbjct  180  HHGNKQDLKHEGRRLVDSGRQ-NIDFSNVDISELSSEVINNMETFDVHEFDQYLPLNGHS  238\n"+
"\n"+
"Query  305  GVPATH  310\n"+
"             +PA H\n"+
"Sbjct  239  TIPADH  244\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_003417746.1<a name=XP_003417746></a> PREDICTED: transcription factor SOX-8 [Loxodonta africana]  \n"+
"Length=672\n"+
"\n"+
" Score = 353 bits (907),  Expect = 5e-112, Method: Compositional matrix adjust.\n"+
" Identities = 237/458 (52%), Positives = 284/458 (62%), Gaps = 74/458 (16%)\n"+
"\n"+
"Query  71   VCIREAVSQVLKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAARRKLADQYP  128\n"+
"             CIR+AVSQVLKGYDW+LVPMPVR  G    K KPHVKRPMNAFMVWAQAARRKLADQYP\n"+
"Sbjct  270  ACIRDAVSQVLKGYDWSLVPMPVRGGGGGALKAKPHVKRPMNAFMVWAQAARRKLADQYP  329\n"+
"\n"+
"Query  129  HLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAE  188\n"+
"            HLHNAELSKTLGKLWRLL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK GQ +\n"+
"Sbjct  330  HLHNAELSKTLGKLWRLLSETEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKTGQGD  389\n"+
"\n"+
"Query  189  AEEATEQT-HISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQ-  246\n"+
"             +   E   H+   A++KA          G+ ++H  G+++GQ+ GPPTPPTTPKTD+  \n"+
"Sbjct  390  LDSGAELGHHLGSGAMYKA--------DVGLGDMHHHGDNTGQTHGPPTPPTTPKTDLHH  441\n"+
"\n"+
"Query  247  ----PGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNG  302\n"+
"                 GK +LK EGR L +  RQ  IDF +VDI ELSS+VISN++TFDV+EFDQYLP NG\n"+
"Sbjct  442  PGGGGGKQELKLEGRRLVDSSRQ-NIDFSNVDISELSSEVISNMDTFDVHEFDQYLPLNG  500\n"+
"\n"+
"Query  303  HPGVPATHGQVTYTGSYGISSTAATPASAGHV---WMSKQQAPPPPPQQPPQAPPAPQAP  359\n"+
"            H  + A  GQV   GSYG +S +   A+   V   W  K  +          A P    P\n"+
"Sbjct  501  HSAITAEPGQVA-AGSYGSASYSHAGAATRGVSPAWAHKGAS-------SASASPTEAGP  552\n"+
"\n"+
"Query  360  PQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQ-QQHSPQQI  418\n"+
"            P+P                                 HIKTEQLSPSHYS+Q   +SP   \n"+
"Sbjct  553  PRP---------------------------------HIKTEQLSPSHYSDQLHGNSPSHA  579\n"+
"\n"+
"Query  419  AYSPFN----LPHYSPSYP--PITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPA  472\n"+
"             YS ++    +   SPS     I  SQ DYTD Q +S YY    G  + LY  + Y + +\n"+
"Sbjct  580  DYSSYSAQACITTASPSVSSGSIPGSQCDYTDLQ-ASGYYGPYPGYPSSLYQ-YPYFHSS  637\n"+
"\n"+
"Query  473  QRPMYTPIADTSGVPSIPQTHSP-QHWEQPVYTQLTRP  509\n"+
"            +RP  +P+ +     S+P  HSP  +WEQP+YT LTRP\n"+
"Sbjct  638  RRPYASPLLNGL---SMPAAHSPTSNWEQPMYTTLTRP  672\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ABB02374.2<a name=ABB02374></a> Sox8, partial [Salmo salar]  \n"+
"Length=356\n"+
"\n"+
" Score = 337 bits (863),  Expect = 2e-109, Method: Compositional matrix adjust.\n"+
" Identities = 195/345 (57%), Positives = 224/345 (65%), Gaps = 53/345 (15%)\n"+
"\n"+
"Query  65   EEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLA  124\n"+
"            ++D+FP CIR+AVSQVLKGYDW+LVPMPVR NGS KNKPHVKRPMNAFMVWAQAARRKLA\n"+
"Sbjct  60   DDDRFPACIRDAVSQVLKGYDWSLVPMPVRGNGSLKNKPHVKRPMNAFMVWAQAARRKLA  119\n"+
"\n"+
"Query  125  DQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            DQYPHLHNAELSKTLGKLWRLL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK \n"+
"Sbjct  120  DQYPHLHNAELSKTLGKLWRLLSENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKP  179\n"+
"\n"+
"Query  185  GQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTD  244\n"+
"            GQ++++   E      N ++KA                 PG  +GQ  GPPTPPTTPKTD\n"+
"Sbjct  180  GQSDSDSGAELG----NHMYKA----------------EPGLLAGQPHGPPTPPTTPKTD  219\n"+
"\n"+
"Query  245  V-QPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGH  303\n"+
"            +   GK D+K EGR L + GRQ  IDF +VDI ELS+DVISN+E FDV+EFDQYLP NGH\n"+
"Sbjct  220  LHHGGKQDMKHEGRRLLDSGRQ-NIDFSNVDISELSTDVISNMEAFDVHEFDQYLPLNGH  278\n"+
"\n"+
"Query  304  PGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQ  363\n"+
"                     V + G +G++     PAS    + S   A         ++     +     \n"+
"Sbjct  279  ASTAGA--GVDHHGHHGLN-----PASGAGSYTSYSHATANGAVWSRKSAAMSASSSTSS  331\n"+
"\n"+
"Query  364  AAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYS  408\n"+
"             A PQ                         R HIKTEQLSPSHYS\n"+
"Sbjct  332  EAVPQ------------------------HRAHIKTEQLSPSHYS  352\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KFV48233.1<a name=KFV48233></a> Transcription factor SOX-10, partial [Tyto alba]  \n"+
"Length=289\n"+
"\n"+
" Score = 332 bits (852),  Expect = 6e-109, Method: Compositional matrix adjust.\n"+
" Identities = 181/278 (65%), Positives = 211/278 (76%), Gaps = 17/278 (6%)\n"+
"\n"+
"Query  21   APSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQV  80\n"+
"            +P P+M+ D++     SG+G   +  + Q+++          E+++DKFPVCIREAVSQV\n"+
"Sbjct  24   SPGPSMASDNSPHLASSGNGEMGKVKKEQQDS----------EADDDKFPVCIREAVSQV  73\n"+
"\n"+
"Query  81   LKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG  140\n"+
"            L GYDWTLVPMPVRVNGS+K+KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG\n"+
"Sbjct  74   LSGYDWTLVPMPVRVNGSNKSKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG  133\n"+
"\n"+
"Query  141  KLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISP  200\n"+
"            KLWRLLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+ K  Q E E   E      \n"+
"Sbjct  134  KLWRLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKNGKATQGEGEGQVEGDAGGA  193\n"+
"\n"+
"Query  201  NAI---FKALQADSPHSSSG--MSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKRE  255\n"+
"             AI   +K    D  H   G  MS+ H P   SGQS GPPTPPTTPKT++Q GKAD KRE\n"+
"Sbjct  194  AAIQAHYKNAHLDHRHPGEGSPMSDGH-PEHSSGQSHGPPTPPTTPKTELQAGKADSKRE  252\n"+
"\n"+
"Query  256  GRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNE  293\n"+
"            GR L EGG+ P IDF +VDIGE+S +V+SN+ETFDVNE\n"+
"Sbjct  253  GRSLGEGGK-PHIDFGNVDIGEISHEVMSNMETFDVNE  289\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACZ54381.1<a name=ACZ54381></a> SRY-box 9 protein, partial [Monodelphis domestica]  \n"+
"Length=157\n"+
"\n"+
" Score = 327 bits (838),  Expect = 8e-109, Method: Compositional matrix adjust.\n"+
" Identities = 155/157 (99%), Positives = 155/157 (99%), Gaps = 0/157 (0%)\n"+
"\n"+
"Query  60   LKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAA  119\n"+
"            LKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAA\n"+
"Sbjct  1    LKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAA  60\n"+
"\n"+
"Query  120  RRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            RRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR\n"+
"Sbjct  61   RRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  120\n"+
"\n"+
"Query  180  KSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSS  216\n"+
"            KSVKNGQAE EE TEQTHISPNAIFKALQADSPHSSS\n"+
"Sbjct  121  KSVKNGQAEQEEGTEQTHISPNAIFKALQADSPHSSS  157\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010171101.1<a name=XP_010171101></a> PREDICTED: transcription factor SOX-9-like, partial [Caprimulgus \n"+
"carolinensis]  \n"+
"Length=231\n"+
"\n"+
" Score = 329 bits (844),  Expect = 2e-108, Method: Compositional matrix adjust.\n"+
" Identities = 179/199 (90%), Positives = 183/199 (92%), Gaps = 4/199 (2%)\n"+
"\n"+
"Query  144  RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAI  203\n"+
"            RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQ+E EE +EQTHISPNAI\n"+
"Sbjct  19   RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQSEQEEGSEQTHISPNAI  78\n"+
"\n"+
"Query  204  FKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGG  263\n"+
"            FKALQADSP SSS +SEVHSPGEHSGQSQGPPTPPTTPKTD QPGK DLKREGRPL EGG\n"+
"Sbjct  79   FKALQADSPQSSSSISEVHSPGEHSGQSQGPPTPPTTPKTDAQPGKQDLKREGRPLQEGG  138\n"+
"\n"+
"Query  264  RQPP-IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATH---GQVTYTGSY  319\n"+
"            RQPP IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATH   GQVTYTGSY\n"+
"Sbjct  139  RQPPHIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQPGQVTYTGSY  198\n"+
"\n"+
"Query  320  GISSTAATPASAGHVWMSK  338\n"+
"            GISST  +   AGHVWMSK\n"+
"Sbjct  199  GISSTTGSQTGAGHVWMSK  217\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EMP27032.1<a name=EMP27032></a> Transcription factor SOX-10 [Chelonia mydas]  \n"+
"Length=423\n"+
"\n"+
" Score = 336 bits (861),  Expect = 3e-108, Method: Compositional matrix adjust.\n"+
" Identities = 195/333 (59%), Positives = 224/333 (67%), Gaps = 55/333 (17%)\n"+
"\n"+
"Query  21   APSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQV  80\n"+
"            +P P+M+ D+      SGSG   +  + Q+++          E+++DKFPVCIREAVSQV\n"+
"Sbjct  24   SPGPSMASDTTSHLTSSGSGEMGKVKKEQQDS----------ETDDDKFPVCIREAVSQV  73\n"+
"\n"+
"Query  81   LKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG  140\n"+
"            L GYDWTLVPMPVRVNGS+K+KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG\n"+
"Sbjct  74   LSGYDWTLVPMPVRVNGSNKSKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG  133\n"+
"\n"+
"Query  141  KLWR-----------------------------LLNESEKRPFVEEAERLRVQHKKDHPD  171\n"+
"            KLWR                             LLNES+KRPF+EEAERLR+QHKKDHPD\n"+
"Sbjct  134  KLWRLLNESDKRPFIEEAERLRMQHKKDHPDYKLLNESDKRPFIEEAERLRMQHKKDHPD  193\n"+
"\n"+
"Query  172  YKYQPRRRKSVKNGQAEAEEATEQTHISPNAI------FKALQADSPHSSSG--MSEVHS  223\n"+
"            YKYQPRRR   KNG+A   E   Q              +K    D  H   G  MS+ H \n"+
"Sbjct  194  YKYQPRRR---KNGKASQGEGEGQAEGEAGGAAAIQAHYKNAHLDHRHPGEGSPMSDGH-  249\n"+
"\n"+
"Query  224  PGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVI  283\n"+
"            P   SGQS GPPTPPTTPKT++Q GKAD KREGR L EGG+ P IDF +VDIGE+S +V+\n"+
"Sbjct  250  PEHSSGQSHGPPTPPTTPKTELQAGKADSKREGRSLGEGGK-PHIDFGNVDIGEISHEVM  308\n"+
"\n"+
"Query  284  SNIETFDVNEFDQYLPPNGHPGVPATHGQVTYT  316\n"+
"            SN+ETFDVNEFDQYLPPNGH G P   G + YT\n"+
"Sbjct  309  SNMETFDVNEFDQYLPPNGHAGHP---GHIAYT  338\n"+
"\n"+
"\n"+
" Score = 119 bits (297),  Expect = 3e-26, Method: Compositional matrix adjust.\n"+
" Identities = 56/95 (59%), Positives = 73/95 (77%), Gaps = 3/95 (3%)\n"+
"\n"+
"Query  415  PQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQR  474\n"+
"            P  IAY+  +LPHY  ++P I+R Q+DY DHQ S  YYSH++ Q +GLYS F+YM P+QR\n"+
"Sbjct  332  PGHIAYTSLSLPHYGSAFPSISRPQFDYPDHQPSGPYYSHSS-QASGLYSAFSYMGPSQR  390\n"+
"\n"+
"Query  475  PMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            P+YT I+D +  PS+PQ+HSP HWEQPVYT L+RP\n"+
"Sbjct  391  PLYTAISDPA--PSVPQSHSPTHWEQPVYTTLSRP  423\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ABG89133.1<a name=ABG89133></a> sox9b, partial [Kryptolebias marmoratus]  \n"+
"Length=197\n"+
"\n"+
" Score = 325 bits (832),  Expect = 3e-107, Method: Compositional matrix adjust.\n"+
" Identities = 174/200 (87%), Positives = 180/200 (90%), Gaps = 5/200 (3%)\n"+
"\n"+
"Query  82   KGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGK  141\n"+
"            KGYDWTLVPMPVRVNGSSK+KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGK\n"+
"Sbjct  1    KGYDWTLVPMPVRVNGSSKSKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGK  60\n"+
"\n"+
"Query  142  LWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPN  201\n"+
"            LWRLLNE EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQ+EAE+ +E THISPN\n"+
"Sbjct  61   LWRLLNEVEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQSEAED-SEPTHISPN  119\n"+
"\n"+
"Query  202  AIFKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLP  260\n"+
"            AIFKAL QADSP SS  M E HSPGEHSGQSQGPPTPPTTPKTD+   KADLKREGRP+ \n"+
"Sbjct  120  AIFKALQQADSPASS--MGEAHSPGEHSGQSQGPPTPPTTPKTDLSSSKADLKREGRPVQ  177\n"+
"\n"+
"Query  261  EG-GRQPPIDFRDVDIGELS  279\n"+
"            EG  RQ  IDF  VDIGE S\n"+
"Sbjct  178  EGTSRQLNIDFGAVDIGEHS  197\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012790332.1<a name=XP_012790332></a> PREDICTED: transcription factor SOX-9 [Sorex araneus]  \n"+
"Length=272\n"+
"\n"+
" Score = 326 bits (835),  Expect = 1e-106, Method: Compositional matrix adjust.\n"+
" Identities = 175/179 (98%), Positives = 175/179 (98%), Gaps = 1/179 (1%)\n"+
"\n"+
"Query  143  WRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNA  202\n"+
"             RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA EQTHISPNA\n"+
"Sbjct  67   GRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEAAEQTHISPNA  126\n"+
"\n"+
"Query  203  IFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEG  262\n"+
"            IFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEG\n"+
"Sbjct  127  IFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEG  186\n"+
"\n"+
"Query  263  GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATH-GQVTYTGSYG  320\n"+
"            GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP TH GQVTYTGSYG\n"+
"Sbjct  187  GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPTTHGGQVTYTGSYG  245\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_016157275.1<a name=XP_016157275></a> PREDICTED: transcription factor SOX-8 [Ficedula albicollis]  \n"+
"\n"+
"Length=444\n"+
"\n"+
" Score = 330 bits (846),  Expect = 8e-106, Method: Compositional matrix adjust.\n"+
" Identities = 173/252 (69%), Positives = 202/252 (80%), Gaps = 7/252 (3%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLAD  125\n"+
"            +++FP CIR+AVSQVLKGYDW+LVPMPVR NGS K KPHVKRPMNAFMVWAQAARRKLAD\n"+
"Sbjct  137  DERFPACIRDAVSQVLKGYDWSLVPMPVRGNGSLKAKPHVKRPMNAFMVWAQAARRKLAD  196\n"+
"\n"+
"Query  126  QYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNG  185\n"+
"            QYPHLHNAELSKTLGKLWRLL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK G\n"+
"Sbjct  197  QYPHLHNAELSKTLGKLWRLLSENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKAG  256\n"+
"\n"+
"Query  186  QAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDV  245\n"+
"            Q++++   E +H + + ++K   AD+     GM++ H  G+H+GQ  GPPTPPTTPKTD+\n"+
"Sbjct  257  QSDSDSGAELSHHAGSQLYK---ADT--GLGGMADSHHHGDHAGQPHGPPTPPTTPKTDL  311\n"+
"\n"+
"Query  246  QPG-KADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHP  304\n"+
"              G K +LK EGR L E GRQ  IDF +VDI ELSS+VI+N+ETFDV+EFDQYL P    \n"+
"Sbjct  312  HHGSKQELKHEGRRLVESGRQ-NIDFSNVDISELSSEVINNMETFDVHEFDQYLGPAAAA  370\n"+
"\n"+
"Query  305  GVPATHGQVTYT  316\n"+
"                +  Q  YT\n"+
"Sbjct  371  AASFSSSQCDYT  382\n"+
"\n"+
"\n"+
" Score = 53.9 bits (128),  Expect = 9e-05, Method: Compositional matrix adjust.\n"+
" Identities = 36/72 (50%), Positives = 45/72 (63%), Gaps = 6/72 (8%)\n"+
"\n"+
"Query  439  QYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP-QH  497\n"+
"            Q DYTD Q SS+YY+   G  + LY  + Y + ++RP  TPI +     SIP  HSP  +\n"+
"Sbjct  378  QCDYTDLQ-SSNYYNPYPGYASSLYQ-YPYFHSSRRPYATPILNG---LSIPPAHSPTAN  432\n"+
"\n"+
"Query  498  WEQPVYTQLTRP  509\n"+
"            WEQPVYT LTRP\n"+
"Sbjct  433  WEQPVYTTLTRP  444\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAS29568.1<a name=BAS29568></a> SRY (sex determining region Y)-box9, partial [Homo sapiens]  \n"+
"\n"+
"Length=159\n"+
"\n"+
" Score = 312 bits (799),  Expect = 8e-103, Method: Compositional matrix adjust.\n"+
" Identities = 159/159 (100%), Positives = 159/159 (100%), Gaps = 0/159 (0%)\n"+
"\n"+
"Query  351  QAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQ  410\n"+
"            QAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQ\n"+
"Sbjct  1    QAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQ  60\n"+
"\n"+
"Query  411  QQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMN  470\n"+
"            QQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMN\n"+
"Sbjct  61   QQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMN  120\n"+
"\n"+
"Query  471  PAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            PAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  121  PAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  159\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AHK05950.1<a name=AHK05950></a> Sox8 [Plecoglossus altivelis]  \n"+
"Length=479\n"+
"\n"+
" Score = 321 bits (822),  Expect = 1e-101, Method: Compositional matrix adjust.\n"+
" Identities = 221/466 (47%), Positives = 269/466 (58%), Gaps = 63/466 (14%)\n"+
"\n"+
"Query  65   EEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLA  124\n"+
"            ++D+FP CIR+AVSQVLKGYDW+LVPMP R + S KNKPHVKRPMNAFMVWAQAARRKLA\n"+
"Sbjct  56   DDDRFPACIRDAVSQVLKGYDWSLVPMPPRGDRSMKNKPHVKRPMNAFMVWAQAARRKLA  115\n"+
"\n"+
"Query  125  DQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            DQYPHLHNAELSKTLGKLWRLL+ESEKRPF+EEAERLR+QHKKD+PDYKYQPRRRKS K \n"+
"Sbjct  116  DQYPHLHNAELSKTLGKLWRLLSESEKRPFMEEAERLRLQHKKDYPDYKYQPRRRKSTKP  175\n"+
"\n"+
"Query  185  GQAEAEEATEQTHISPNAIFK---ALQADSPHSSSGMSEVHSPGEH---SGQSQGPPTPP  238\n"+
"            GQA+++  TE T      ++K    L       +S + E+H+P  H    GQ   PP PP\n"+
"Sbjct  176  GQADSDPGTEMTDQGGVQVYKTEPGLGLGQGRLAS-IGEIHNPHHHPERGGQQHAPPNPP  234\n"+
"\n"+
"Query  239  TTPKTDVQP----GKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEF  294\n"+
"            T P T        GK + +R       GG +  IDF  VDI ELS+DVISN+E FDV+EF\n"+
"Sbjct  235  TPPTTPKTELHLGGKYECRRPLEIHTGGGGRQNIDFSHVDISELSTDVISNMEGFDVHEF  294\n"+
"\n"+
"Query  295  DQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGH---VWMSKQQAPPPPPQQPPQ  351\n"+
"            DQYLPP+GH   P +  Q    G    SSTA+  +   H    W  K  A PP    P  \n"+
"Sbjct  295  DQYLPPSGHSSTPGSSDQG--LGHNPPSSTASLSSPNPHPHSGWGHKAGAVPPSSLSPG-  351\n"+
"\n"+
"Query  352  APPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQ  411\n"+
"                                            +   +P Q QR HIKTEQ+SPSHYS Q \n"+
"Sbjct  352  -------------------------------NSNHGDPHQQQRPHIKTEQMSPSHYSSQP  380\n"+
"\n"+
"Query  412  QHSPQQIA-----YSPFNL---PHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLY  463\n"+
"                         Y+P  L   P  +PS  PI   Q DYTD Q   S+Y   +G   GLY\n"+
"Sbjct  381  SQCSSPPPPPHPEYTPLGLGSCPSLTPSSIPIP--QCDYTDLQG-PSFYGAYSGYQAGLY  437\n"+
"\n"+
"Query  464  STFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"              + Y + ++R   + + ++    +   + S   WEQPV+T L+RP\n"+
"Sbjct  438  Q-YPYFSSSRRTYSSSLVNSL---ASAHSSSTAAWEQPVFTSLSRP  479\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">CBN81184.1<a name=CBN81184></a> Transcription factor Sox-8 [Dicentrarchus labrax]  \n"+
"Length=482\n"+
"\n"+
" Score = 318 bits (815),  Expect = 1e-100, Method: Compositional matrix adjust.\n"+
" Identities = 223/494 (45%), Positives = 281/494 (57%), Gaps = 69/494 (14%)\n"+
"\n"+
"Query  39   SGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGS  98\n"+
"            +GSD +    Q     K E  ++   E+++FP CIR+AVSQVLKGYDW+L+PMP +    \n"+
"Sbjct  35   AGSDAQEAARQPGFTHKPERSMESSMEDERFPACIRDAVSQVLKGYDWSLLPMPSQGERG  94\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"             K+KPHVKRPMNAFMVWAQAAR+KLADQYPHLHNAELSKTLGKLWRLL+E+EKRPF+EEA\n"+
"Sbjct  95   LKSKPHVKRPMNAFMVWAQAARKKLADQYPHLHNAELSKTLGKLWRLLSETEKRPFIEEA  154\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA-TEQTHISPNAIFKALQADSPHSSSG  217\n"+
"            ERLR+QHKKD+PDYKYQPRRRK+ K GQ +      +Q H     ++K     +  + +G\n"+
"Sbjct  155  ERLRLQHKKDYPDYKYQPRRRKNTKLGQGDCRPGLVQQQH--QQGLYKTEPGVARLTGAG  212\n"+
"\n"+
"Query  218  MSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREG-RPL-PEGGRQPP-----IDF  270\n"+
"                H   + +GQS GPPTPPTTPKTD+  G    K EG RP+    G  PP     IDF\n"+
"Sbjct  213  EVHHHYHPDRTGQSHGPPTPPTTPKTDLHAGN---KHEGHRPVDSSAGSVPPTTRQNIDF  269\n"+
"\n"+
"Query  271  RDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPAT-----HGQVTYTGSYGISSTA  325\n"+
"             +VDI ELS+DVIS I+ FDV+EFDQYLPPN H     T     HG     GS+ + +  \n"+
"Sbjct  270  SNVDISELSTDVISTIDGFDVHEFDQYLPPNSHSSTVLTPPDTSHGHNNPPGSFTLPNIH  329\n"+
"\n"+
"Query  326  ATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTL  385\n"+
"            +   S    W              P++  +   PP   +  P            H L   \n"+
"Sbjct  330  SHSHSLS-TWT-------------PKSGTSTGMPPSSSSRDP------------HGL---  360\n"+
"\n"+
"Query  386  SSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPIT---------  436\n"+
"                  SQ+  IKTEQ+SP HYS     +P      P   P Y+     I          \n"+
"Sbjct  361  --HEDTSQKPQIKTEQMSPGHYSSSCTSTP------PPPQPEYTSLGSGICPSSTSSSSS  412\n"+
"\n"+
"Query  437  RSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP-  495\n"+
"             +Q DYTD Q SSS+YS  +G    LY  + Y + ++RP  TP+ ++  +   P  HSP \n"+
"Sbjct  413  TNQSDYTDLQ-SSSFYSAFSGYPAHLYQ-YPYFHSSRRPYTTPLINSLAL--APPPHSPP  468\n"+
"\n"+
"Query  496  QHWEQPVYTQLTRP  509\n"+
"              WEQP+YT LTRP\n"+
"Sbjct  469  SGWEQPIYTTLTRP  482\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACZ65967.1<a name=ACZ65967></a> Sox8b [Misgurnus anguillicaudatus]  \n"+
"Length=414\n"+
"\n"+
" Score = 316 bits (809),  Expect = 1e-100, Method: Compositional matrix adjust.\n"+
" Identities = 229/505 (45%), Positives = 274/505 (54%), Gaps = 96/505 (19%)\n"+
"\n"+
"Query  10   MTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKF  69\n"+
"            M+ E +K  +G  S     D       S S SD + +  Q  T  K  P+++   E+ +F\n"+
"Sbjct  1    MSKEPDKNSTGTESSAFLGDVDSDCASSPSMSDDQESHSQLGTSNK--PNIE---EDGRF  55\n"+
"\n"+
"Query  70   PVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPH  129\n"+
"            P CIR+AVSQVLKGYDW+L+PMP++ N S K+KPHVKRPMNAFMVWAQAARRKLADQYPH\n"+
"Sbjct  56   PPCIRDAVSQVLKGYDWSLLPMPMQGNRSLKDKPHVKRPMNAFMVWAQAARRKLADQYPH  115\n"+
"\n"+
"Query  130  LHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEA  189\n"+
"            LHNAELSKTLGKLWRLL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS+K  Q+E \n"+
"Sbjct  116  LHNAELSKTLGKLWRLLSENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSMKPDQSEP  175\n"+
"\n"+
"Query  190  EEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGK  249\n"+
"            +   E+ H   + I+KA                       QS GPPTPPTTPK D   G \n"+
"Sbjct  176  D---EKNHHPTDHIYKAEPV--------------------QSHGPPTPPTTPKADQHQGA  212\n"+
"\n"+
"Query  250  ADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPAT  309\n"+
"               K E R   E  RQ  IDF +VDI ELSSDVI ++  FDV EFDQYLP NGH  V   \n"+
"Sbjct  213  ---KLESRRASENVRQ-NIDFSNVDISELSSDVICSMGPFDVREFDQYLPLNGHGAVNIE  268\n"+
"\n"+
"Query  310  HGQVTYTGSYGISST--AATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPP  367\n"+
"            +G   ++ S G  ST       S G  W     +P                         \n"+
"Sbjct  269  NGGGQHS-SPGCFSTYHHHHAHSGGSTWNKDSGSP-------------------------  302\n"+
"\n"+
"Query  368  QQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPH  427\n"+
"                        H  T  SS+    QR  IKTEQLSPSHY E                 H\n"+
"Sbjct  303  --------STSLHNGTNESSQ----QRPLIKTEQLSPSHYGES----------------H  334\n"+
"\n"+
"Query  428  YSPSYPPITRSQYDYTDHQN--SSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSG  485\n"+
"             SP    +  S    TD  +  +S+YY+   G  + +Y  + Y + ++R    P+ +T  \n"+
"Sbjct  335  GSPIQSELGSSSNSLTDCSDLHNSTYYTTFPGYPSSIYQ-YPYFHSSRRSYVAPVLNTLS  393\n"+
"\n"+
"Query  486  VPSIPQTHSP-QHWEQPVYTQLTRP  509\n"+
"             PS    HSP   WEQPVYT LTRP\n"+
"Sbjct  394  SPS----HSPGASWEQPVYTTLTRP  414\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_004449420.1<a name=XP_004449420></a> PREDICTED: transcription factor SOX-8 [Dasypus novemcinctus] \n"+
" \n"+
"Length=422\n"+
"\n"+
" Score = 315 bits (807),  Expect = 3e-100, Method: Compositional matrix adjust.\n"+
" Identities = 208/447 (47%), Positives = 251/447 (56%), Gaps = 84/447 (19%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLAD  125\n"+
"            +++FP CIR+AVSQVLKGYDW+LVP+PVR  G+ K KPHVKRPMNAFMVWAQAARRKLAD\n"+
"Sbjct  57   DERFPACIRDAVSQVLKGYDWSLVPLPVRGGGALKAKPHVKRPMNAFMVWAQAARRKLAD  116\n"+
"\n"+
"Query  126  QYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNG  185\n"+
"            QYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKK+HPDYKYQPRRRK  K G\n"+
"Sbjct  117  QYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKEHPDYKYQPRRRKGAKAG  176\n"+
"\n"+
"Query  186  QAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDV  245\n"+
"              +A+  TE                 P    G   +H   +H+G    P  P T     +\n"+
"Sbjct  177  HGDADAGTE-----------------PGRHPGGDGMHHHSDHTGGHGLPXPPTTPKTDPL  219\n"+
"\n"+
"Query  246  QPG--KADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGH  303\n"+
"              G  K +LK EGR   +GGRQ  IDF +VDI ELSSDV+  ++ FDV+EFDQYLP   H\n"+
"Sbjct  220  PGGGSKPELKLEGRRAADGGRQN-IDFSNVDISELSSDVVEGMDAFDVHEFDQYLPLGAH  278\n"+
"\n"+
"Query  304  PGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQ  363\n"+
"              +PA  GQ            A  P S          AP   P    +A P       P+\n"+
"Sbjct  279  AALPAEPGQA-----------AGGPYSG---------APYVHPGWAHKASP-------PE  311\n"+
"\n"+
"Query  364  AAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPF  423\n"+
"            A PP                          R HIKTEQLSP HY ++   SP   + +  \n"+
"Sbjct  312  AGPP--------------------------RPHIKTEQLSPGHYGDRPHGSPGAYS-AQA  344\n"+
"\n"+
"Query  424  NLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADT  483\n"+
"             +   +P+      SQ DY+D Q S  YYS   G  +GLY  + Y + ++RP   P+ + \n"+
"Sbjct  345  CVAAAAPAAGSCAGSQCDYSDLQ-SPGYYSPYPGYPSGLY-QYPYFHSSRRPYAAPLLNG  402\n"+
"\n"+
"Query  484  SGVPSIPQTHSP-QHWEQPVYTQLTRP  509\n"+
"                     HSP  +W+ PVYT L+RP\n"+
"Sbjct  403  -------LAHSPTSNWDPPVYTTLSRP  422\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014959333.1<a name=XP_014959333></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-8 isoform \n"+
"X1 [Ovis aries]  \n"+
"Length=705\n"+
"\n"+
" Score = 322 bits (824),  Expect = 2e-99, Method: Compositional matrix adjust.\n"+
" Identities = 183/281 (65%), Positives = 210/281 (75%), Gaps = 20/281 (7%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAARRKL  123\n"+
"            +++FP CIR+AVSQVLKGYDW+LVPMPVR  G    K KPHVKRPMNAFMVWAQAARRKL\n"+
"Sbjct  61   DERFPACIRDAVSQVLKGYDWSLVPMPVRGGGGGALKAKPHVKRPMNAFMVWAQAARRKL  120\n"+
"\n"+
"Query  124  ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK\n"+
"Sbjct  121  ADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  180\n"+
"\n"+
"Query  184  NGQAEAEEATEQTHISPNAIFK--ALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTP  241\n"+
"             GQ++++   E+ H  P  + K  A   D+ H S          +H+GQ+ GPPTPPTTP\n"+
"Sbjct  181  TGQSDSDSGAERGH-HPGGVCKTDAXPGDAHHHS----------DHTGQTHGPPTPPTTP  229\n"+
"\n"+
"Query  242  KTDV-QPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP  300\n"+
"            KTD+   GK +LK EGR L + GRQ  IDF +VDI ELSS+VI N++TFDV+EFDQYLP \n"+
"Sbjct  230  KTDLHHGGKQELKLEGRRLVDSGRQ-NIDFSNVDISELSSEVIGNMDTFDVHEFDQYLPL  288\n"+
"\n"+
"Query  301  NGHPGVPATHGQVTYTGSYGISS---TAATPASAGHVWMSK  338\n"+
"            NGH  +PA  GQ    GSYG +S   + A    A  VW  K\n"+
"Sbjct  289  NGHSALPAEPGQPAAAGSYGGASYSHSGAASIGASPVWAHK  329\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006745230.1<a name=XP_006745230></a> PREDICTED: transcription factor SOX-9-like [Leptonychotes weddellii] \n"+
" \n"+
"Length=282\n"+
"\n"+
" Score = 307 bits (787),  Expect = 3e-99, Method: Compositional matrix adjust.\n"+
" Identities = 144/144 (100%), Positives = 144/144 (100%), Gaps = 0/144 (0%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL\n"+
"Sbjct  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWR  144\n"+
"            RKLADQYPHLHNAELSKTLGKLWR\n"+
"Sbjct  121  RKLADQYPHLHNAELSKTLGKLWR  144\n"+
"\n"+
"\n"+
" Score = 256 bits (655),  Expect = 2e-79, Method: Compositional matrix adjust.\n"+
" Identities = 126/131 (96%), Positives = 127/131 (97%), Gaps = 0/131 (0%)\n"+
"\n"+
"Query  379  AHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRS  438\n"+
"            AHTLTTLSSEPGQSQRTHIKTEQLSPSHYSE QQHSPQQIAYSPFNLPHYSPSYPPITRS\n"+
"Sbjct  152  AHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEPQQHSPQQIAYSPFNLPHYSPSYPPITRS  211\n"+
"\n"+
"Query  439  QYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHW  498\n"+
"            QYDY DHQNS SYYSHAAGQG+ LYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHW\n"+
"Sbjct  212  QYDYPDHQNSGSYYSHAAGQGSSLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHW  271\n"+
"\n"+
"Query  499  EQPVYTQLTRP  509\n"+
"            EQPVYTQLTRP\n"+
"Sbjct  272  EQPVYTQLTRP  282\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010776021.1<a name=XP_010776021></a> PREDICTED: transcription factor Sox-8-like [Notothenia coriiceps] \n"+
" \n"+
"Length=444\n"+
"\n"+
" Score = 310 bits (794),  Expect = 5e-98, Method: Compositional matrix adjust.\n"+
" Identities = 228/497 (46%), Positives = 279/497 (56%), Gaps = 85/497 (17%)\n"+
"\n"+
"Query  31   AGSPCP-SGSGSDTEN-TRPQENTFPKGEPDLKKESEE----DKFPVCIREAVSQVLKGY  84\n"+
"            AGS  P S  GSD+E+ T P  +  P+    +  E E     D+FP CIR+AVSQVLKGY\n"+
"Sbjct  15   AGSDSPLSKHGSDSESPTSPAGSEAPEPSRKITHEPESSVKADRFPACIRDAVSQVLKGY  74\n"+
"\n"+
"Query  85   DWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWR  144\n"+
"            DW+L+P+P     + K++PHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWR\n"+
"Sbjct  75   DWSLLPVPAMGERALKSQPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWR  134\n"+
"\n"+
"Query  145  LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIF  204\n"+
"            LL+E+EKRPFV+EAERLR+QHKKD+PDYKYQPRRRKS K GQ +           P  + \n"+
"Sbjct  135  LLSETEKRPFVQEAERLRMQHKKDYPDYKYQPRRRKSTKPGQGDGR---------PGLVL  185\n"+
"\n"+
"Query  205  KALQADSPHSSSGMSEVHS-PGEHSGQSQGPPTPPTTPKTDVQPGKADLKREG-RPL---  259\n"+
"            +  Q   P+      E H    + +GQS GPPTPPTTPKTD+  G    K EG RP    \n"+
"Sbjct  186  QN-QQQGPYKIEPGDEYHQYHTDKTGQSHGPPTPPTTPKTDLHMGN---KHEGQRPADTS  241\n"+
"\n"+
"Query  260  --PEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGH----PGVPATHGQV  313\n"+
"                GGRQ  IDF  VDI ELS DVIS IE FDVNEFDQYLPPNG     P   +THG  \n"+
"Sbjct  242  TSTTGGRQ-NIDFSIVDISELSPDVISTIEAFDVNEFDQYLPPNGSTLLTPTDSSTHGHN  300\n"+
"\n"+
"Query  314  TYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAP  373\n"+
"            T+                          P   P  P +AP +  A               \n"+
"Sbjct  301  TFL------------------------LPSLHPHIPARAPKSGSA----------SSLIC  326\n"+
"\n"+
"Query  374  PQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYP  433\n"+
"             + P+ H  T          +  IKTEQ+SP HYS     +P Q  Y+ F+    S ++ \n"+
"Sbjct  327  RETPRLHGDT----------KPQIKTEQMSPDHYSSSS--TPPQSDYTSFSSGSSSNTH-  373\n"+
"\n"+
"Query  434  PITRSQYDYTDHQNSSSYYSHAAGQ-GTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQT  492\n"+
"                 Q DY+D Q S  Y S  +G    GLY  + Y + ++RP  +P+ ++  +   P +\n"+
"Sbjct  374  -----QSDYSDLQGSGFYSSAFSGYPAAGLYQ-YPYFHSSRRPYVSPLINSLALAPPPHS  427\n"+
"\n"+
"Query  493  HSPQHWEQPVYTQLTRP  509\n"+
"              P  WEQPVYT L+RP\n"+
"Sbjct  428  PPPLVWEQPVYTTLSRP  444\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006146498.1<a name=XP_006146498></a> PREDICTED: transcription factor SOX-8 [Tupaia chinensis]  \n"+
"Length=525\n"+
"\n"+
" Score = 310 bits (794),  Expect = 5e-97, Method: Compositional matrix adjust.\n"+
" Identities = 218/437 (50%), Positives = 256/437 (59%), Gaps = 59/437 (14%)\n"+
"\n"+
"Query  81   LKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKT  138\n"+
"            L GYDW+LVPMPVR  G    K KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKT\n"+
"Sbjct  140  LSGYDWSLVPMPVRGGGGGALKAKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKT  199\n"+
"\n"+
"Query  139  LGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHI  198\n"+
"            LGKLWRLL+ESEKRPFV+EAE LRVQHKKDHPDYKYQPRRRK  K GQ + +   E  H \n"+
"Sbjct  200  LGKLWRLLSESEKRPFVDEAEPLRVQHKKDHPDYKYQPRRRKGAKAGQGDPDAGAELGHH  259\n"+
"\n"+
"Query  199  SPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDV-QPG-KADLKREG  256\n"+
"               A     +AD      G+ + H   +H GQ+ GPPTPPTTPKTD+  PG K +LK EG\n"+
"Sbjct  260  PGGAA--GYKAD-----VGLGDTHHHADHPGQTHGPPTPPTTPKTDLHHPGSKQELKLEG  312\n"+
"\n"+
"Query  257  RPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYT  316\n"+
"            R L + GRQ  IDF +VDI ELSS+V+ N++TFDV+EFDQYLP NGH   PA  GQ   T\n"+
"Sbjct  313  RRLVDTGRQ-NIDFSNVDISELSSEVMGNMDTFDVHEFDQYLPLNGHSATPAEPGQAV-T  370\n"+
"\n"+
"Query  317  GSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQ  376\n"+
"             SYG +S      + G           P P   P+  PA  A P    AP          \n"+
"Sbjct  371  SSYGSTSYPHAGTAGGG----------PSPGWAPKGAPAASASPTEAGAP----------  410\n"+
"\n"+
"Query  377  PQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLP---HYSPSYP  433\n"+
"                             R HIKTE+LSP  YS+Q   SP +  +  ++       + S  \n"+
"Sbjct  411  -----------------RPHIKTERLSPGRYSDQPHGSPGRSDFGSYSAQAGMATAASVG  453\n"+
"\n"+
"Query  434  PITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTH  493\n"+
"                 Q DY D Q +  YYS   G   GLY    Y + ++RP  +P+ +     S+P  H\n"+
"Sbjct  454  SFAGPQCDYADLQ-APGYYSPYPGYAPGLYQC-PYFHSSRRPYASPLLNGL---SLPPAH  508\n"+
"\n"+
"Query  494  S-PQHWEQPVYTQLTRP  509\n"+
"            S P  W+QPVYT LTRP\n"+
"Sbjct  509  SPPGTWDQPVYTTLTRP  525\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KTG34073.1<a name=KTG34073></a> hypothetical protein cypCar_00009421 [Cyprinus carpio]  \n"+
"Length=378\n"+
"\n"+
" Score = 305 bits (780),  Expect = 8e-97, Method: Compositional matrix adjust.\n"+
" Identities = 167/270 (62%), Positives = 199/270 (74%), Gaps = 32/270 (12%)\n"+
"\n"+
"Query  60   LKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAA  119\n"+
"            +K + ++D+FP+ IREAVSQVL GYDWTLVPMPVRVN  SKNKPHVKRPMNAFMVWAQAA\n"+
"Sbjct  63   VKSDEDDDRFPIGIREAVSQVLNGYDWTLVPMPVRVNSGSKNKPHVKRPMNAFMVWAQAA  122\n"+
"\n"+
"Query  120  RRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            RRKLADQYPHLHNAELSKTLGKLWRLLNES+KRPF+EEAERLR QHKKD+P+YKYQPRRR\n"+
"Sbjct  123  RRKLADQYPHLHNAELSKTLGKLWRLLNESDKRPFIEEAERLRKQHKKDYPEYKYQPRRR  182\n"+
"\n"+
"Query  180  KSVK-------NGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEH---SG  229\n"+
"            K+ K       +G +E E +  Q+H      +K+L  +  HS +  S +   G H   +G\n"+
"Sbjct  183  KNGKPGSSSEGDGHSEGEVSHSQSH------YKSLHLEVAHSGAAGSPL-GDGHHPHTTG  235\n"+
"\n"+
"Query  230  QSQGPPTPPTTPKTDVQPGK-ADLKREGRPLPEG--------------GRQPPIDFRDVD  274\n"+
"            QS  PPTPPTTPKT++Q GK ++ KREG     G                +P IDF +VD\n"+
"Sbjct  236  QSHSPPTPPTTPKTELQGGKSSEGKREGGASRSGLGVGADGSSASSSASGKPHIDFGNVD  295\n"+
"\n"+
"Query  275  IGELSSDVISNIETFDVNEFDQYLPPNGHP  304\n"+
"            IGE+S +V++N+E FDVNEFDQYLPPNGHP\n"+
"Sbjct  296  IGEISHEVMANMEPFDVNEFDQYLPPNGHP  325\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAO39385.1<a name=AAO39385></a> transcription factor sox-9, partial [Chelydra serpentina]  \n"+
"Length=198\n"+
"\n"+
" Score = 294 bits (752),  Expect = 4e-95, Method: Compositional matrix adjust.\n"+
" Identities = 165/224 (74%), Positives = 172/224 (77%), Gaps = 31/224 (14%)\n"+
"\n"+
"Query  257  RPLPEGGRQPP-IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQ---  312\n"+
"            RPL EGGRQPP IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQ   \n"+
"Sbjct  1    RPLQEGGRQPPHIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQPGQ  60\n"+
"\n"+
"Query  313  VTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAA  372\n"+
"            VTY+GSYGISSTAAT A AGHVWMSK Q                           QQP  \n"+
"Sbjct  61   VTYSGSYGISSTAATQAGAGHVWMSKPQP--------------------------QQPPP  94\n"+
"\n"+
"Query  373  PPQQPQAHTLTTLSSEPGQSQ-RTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPS  431\n"+
"            PPQ    HT+TTLSSE G SQ RTHIKTEQLSPSHYSEQQQHSPQQ+ YS FNL HYS S\n"+
"Sbjct  95   PPQPQPQHTMTTLSSEQGPSQQRTHIKTEQLSPSHYSEQQQHSPQQLNYSSFNLQHYSSS  154\n"+
"\n"+
"Query  432  YPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRP  475\n"+
"            YP ITRSQYDYTDHQ+S++YYSHAA Q +GLYSTFTYMNP QRP\n"+
"Sbjct  155  YPTITRSQYDYTDHQSSNAYYSHAASQSSGLYSTFTYMNPTQRP  198\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_003779598.1<a name=XP_003779598></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-10 [Pongo \n"+
"abelii]  \n"+
"Length=444\n"+
"\n"+
" Score = 300 bits (769),  Expect = 3e-94, Method: Compositional matrix adjust.\n"+
" Identities = 164/237 (69%), Positives = 188/237 (79%), Gaps = 9/237 (4%)\n"+
"\n"+
"Query  63   ESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRK  122\n"+
"            E+++DKFPVCIREAVSQVL GYDWTLVPMPVRVNG+SK+KPHVKRPMNAFMVWAQAARRK\n"+
"Sbjct  64   EADDDKFPVCIREAVSQVLSGYDWTLVPMPVRVNGASKSKPHVKRPMNAFMVWAQAARRK  123\n"+
"\n"+
"Query  123  L-ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS  181\n"+
"                QYPHLHNAELSKTLGKLWRLLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+\n"+
"Sbjct  124  ARGTQYPHLHNAELSKTLGKLWRLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKN  183\n"+
"\n"+
"Query  182  VKNGQAEAE--EATEQTHISPNAI----FKALQADSPHSSSGMSEVHSPGEH-SGQSQGP  234\n"+
"             K  Q EAE     ++    P  I    +K+   D+ H   G        EH SGQS GP\n"+
"Sbjct  184  GKAAQGEAECPGGEDRARWEPPPIPRPHYKSAHLDNRHPGEGSPMSDGNPEHPSGQSHGP  243\n"+
"\n"+
"Query  235  PTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDV  291\n"+
"            PTPPTTPKT++Q GKAD KR+GR + EGG+ P IDF +VDIGE+S +V+SN+ETFDV\n"+
"Sbjct  244  PTPPTTPKTELQSGKADPKRDGRSMGEGGK-PHIDFGNVDIGEISHEVMSNMETFDV  299\n"+
"\n"+
"\n"+
" Score = 130 bits (327),  Expect = 4e-30, Method: Compositional matrix adjust.\n"+
" Identities = 71/137 (52%), Positives = 93/137 (68%), Gaps = 9/137 (7%)\n"+
"\n"+
"Query  376  QPQAHTLTTLSSEPGQSQRTHIKTEQLSPS---HYSEQQQHSPQQIAYSPFNLPHYSPSY  432\n"+
"            +P    L+T+SS PG   +  +K E   P    HY++Q   S  QIAY+  +LPHY  ++\n"+
"Sbjct  314  KPPGGALSTVSS-PGVDSKAQLKFETAGPQGPPHYTDQP--STSQIAYTSLSLPHYGSAF  370\n"+
"\n"+
"Query  433  PPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQT  492\n"+
"            P I+R Q+DY+DHQ S  YY H +GQ +GLYS F+YM P+QRP+YT I+D S  PS PQ+\n"+
"Sbjct  371  PSISRPQFDYSDHQPSGPYYGH-SGQASGLYSAFSYMGPSQRPLYTAISDPS--PSGPQS  427\n"+
"\n"+
"Query  493  HSPQHWEQPVYTQLTRP  509\n"+
"            HSP HWEQPVYT L+RP\n"+
"Sbjct  428  HSPTHWEQPVYTTLSRP  444\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012590517.1<a name=XP_012590517></a> PREDICTED: transcription factor SOX-10 [Condylura cristata]  \n"+
"\n"+
"Length=414\n"+
"\n"+
" Score = 296 bits (759),  Expect = 4e-93, Method: Compositional matrix adjust.\n"+
" Identities = 190/374 (51%), Positives = 227/374 (61%), Gaps = 58/374 (16%)\n"+
"\n"+
"Query  144  RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAE----EATEQTHIS  199\n"+
"            RLLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+ K  Q EAE    EA +    +\n"+
"Sbjct  91   RLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKNGKAAQGEAECPGGEAEQGGTAA  150\n"+
"\n"+
"Query  200  PNAIFKALQADSPHSSSGMSEVHSPGEH-SGQSQGPPTPPTTPKTDVQPGKADLKREGRP  258\n"+
"              A +K    D  H   G        EH SGQS GPPTPPTTPKT++QPGKAD KR+GRP\n"+
"Sbjct  151  IQAHYKGAHLDHRHPGEGSPMSDGNPEHPSGQSHGPPTPPTTPKTELQPGKADPKRDGRP  210\n"+
"\n"+
"Query  259  LPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGS  318\n"+
"            L EGG+ P IDF +VDIGE+S +V+SN+ETFDV E DQYLPPNGHPG    H        \n"+
"Sbjct  211  LGEGGK-PHIDFGNVDIGEISHEVMSNMETFDVAELDQYLPPNGHPG----HVGGYSAAG  265\n"+
"\n"+
"Query  319  YGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQ  378\n"+
"            YG+ S  A  AS    W+SK                                      P \n"+
"Sbjct  266  YGLGSALAV-ASGHSAWISK--------------------------------------PP  286\n"+
"\n"+
"Query  379  AHTLTTLSSEPGQSQRTHIKTEQLSPS---HYSEQQQHSPQQIAYSPFNLPHYSPSYPPI  435\n"+
"               L T+ S PG   +  +KTE   P    HYS+Q   S  QIAY+  +LPHY  ++P I\n"+
"Sbjct  287  GVALPTV-SPPGVDAKAQVKTETAGPQGPPHYSDQP--STSQIAYTSLSLPHYGSAFPSI  343\n"+
"\n"+
"Query  436  TRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP  495\n"+
"            +R Q+DY+DHQ S  YY H +GQ +GLYS F+YM P+QRP+YT I+D S  PS PQ+HSP\n"+
"Sbjct  344  SRPQFDYSDHQPSGPYYGH-SGQASGLYSAFSYMGPSQRPLYTAISDPS--PSGPQSHSP  400\n"+
"\n"+
"Query  496  QHWEQPVYTQLTRP  509\n"+
"             HWEQPVYT L+RP\n"+
"Sbjct  401  THWEQPVYTTLSRP  414\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014013894.1<a name=XP_014013894></a> PREDICTED: transcription factor SOX-8 isoform X1 [Salmo salar] \n"+
" \n"+
"Length=478\n"+
"\n"+
" Score = 298 bits (764),  Expect = 5e-93, Method: Compositional matrix adjust.\n"+
" Identities = 169/285 (59%), Positives = 198/285 (69%), Gaps = 23/285 (8%)\n"+
"\n"+
"Query  36   PSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRV  95\n"+
"            P+GS        P +   PK    L    E+++FP CIR+AV+QVL GYDW+LVPMP R \n"+
"Sbjct  36   PTGSDGQAPRHSPGDGITPK----LDTGEEDNRFPACIRDAVTQVLNGYDWSLVPMPTRG  91\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"            + + KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLL+ESEKRPFV\n"+
"Sbjct  92   DRALKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLSESEKRPFV  151\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSS  215\n"+
"            EEAERLRVQHKKD+PDYKYQPRRRKS K GQ++++   E  H+ P  ++KA    +  +S\n"+
"Sbjct  152  EEAERLRVQHKKDYPDYKYQPRRRKSTKPGQSDSDSGAELAHLHPGQMYKAEPGLARPTS  211\n"+
"\n"+
"Query  216  SGMSEVH------SPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPID  269\n"+
"             G  + H            GQ  GPPTPPTTPKT++  G   +K EGR          ID\n"+
"Sbjct  212  MGDGQHHLDRTSICCVFSKGQPHGPPTPPTTPKTELHLG---VKHEGR--------QNID  260\n"+
"\n"+
"Query  270  FRDVDIGELSSDVISNIETFDVNEFDQYLPPNGH--PGVPATHGQ  312\n"+
"            F +VDI ELS+DVISN+E FDV+EFDQYLP NGH     P  HGQ\n"+
"Sbjct  261  FSNVDISELSTDVISNMEAFDVHEFDQYLPLNGHGSADAPPNHGQ  305\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005955733.1<a name=XP_005955733></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-10, \n"+
"partial [Pantholops hodgsonii]  \n"+
"Length=560\n"+
"\n"+
" Score = 291 bits (746),  Expect = 2e-89, Method: Compositional matrix adjust.\n"+
" Identities = 199/434 (46%), Positives = 247/434 (57%), Gaps = 67/434 (15%)\n"+
"\n"+
"Query  89   VPMPVRVNGSSKNKPHVKR-----PMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLW  143\n"+
"             P P  V G S+ +  +++     P    + W  A  R      P L N   +  L  + \n"+
"Sbjct  181  TPAPQEVLGGSEREQGLQKAPTFGPAPPTLGWLGAGERAQLGGSPAL-NFPAAPALAGV-  238\n"+
"\n"+
"Query  144  RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAE----EATEQTHIS  199\n"+
"            RLLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+ K  Q E+E    EA +    +\n"+
"Sbjct  239  RLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKNGKAAQGESECPGGEAEQGGAAA  298\n"+
"\n"+
"Query  200  PNAIFKALQADSPHSSSGMSEVHSPGEH-SGQSQGPPTPPTTPKTDVQPGKADLKREGRP  258\n"+
"              A +K+   D  H   G        EH SGQS GPPTPPTTPKT++Q GKAD KR+GR \n"+
"Sbjct  299  IQAHYKSAHLDHRHPGEGSPMSDGNPEHPSGQSHGPPTPPTTPKTELQSGKADPKRDGRS  358\n"+
"\n"+
"Query  259  LPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGS  318\n"+
"            L EGG+ P IDF +VDIGE+S +V+SN+ETFDV E DQYLPPNGHPG    H        \n"+
"Sbjct  359  LGEGGK-PHIDFGNVDIGEISHEVMSNMETFDVAELDQYLPPNGHPG----HVGGYSAAG  413\n"+
"\n"+
"Query  319  YGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQ  378\n"+
"            YG+ S  A   SA   W+SK                                      P \n"+
"Sbjct  414  YGLGSALAVTXSA---WISK--------------------------------------PP  432\n"+
"\n"+
"Query  379  AHTLTTLSSEPGQSQRTHIKTEQLSPS---HYSEQQQHSPQQIAYSPFNLPHYSPSYPPI  435\n"+
"               L T+S  PG   +  +KTE   P    HY++Q   S  QIAY+  +LPHY  ++P I\n"+
"Sbjct  433  GVALPTVSP-PGVDAKAQVKTETAGPQGPPHYADQPSTS--QIAYTSLSLPHYGSAFPSI  489\n"+
"\n"+
"Query  436  TRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP  495\n"+
"            +R Q+DY+DHQ S  YY H +GQ +GLYS F+YM P+QRP+YT I+D S  PS PQ+HSP\n"+
"Sbjct  490  SRPQFDYSDHQPSGPYYGH-SGQTSGLYSAFSYMGPSQRPLYTAISDPS--PSGPQSHSP  546\n"+
"\n"+
"Query  496  QHWEQPVYTQLTRP  509\n"+
"             HWEQPVYT L+RP\n"+
"Sbjct  547  THWEQPVYTTLSRP  560\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006174991.1<a name=XP_006174991></a> PREDICTED: transcription factor SOX-10 [Camelus ferus]  \n"+
"Length=325\n"+
"\n"+
" Score = 284 bits (726),  Expect = 2e-89, Method: Compositional matrix adjust.\n"+
" Identities = 184/376 (49%), Positives = 226/376 (60%), Gaps = 59/376 (16%)\n"+
"\n"+
"Query  142  LWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAE----EATEQTH  197\n"+
"            +W LLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+ K  Q E+E    EA +   \n"+
"Sbjct  1    MW-LLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKNGKAAQGESECPGGEAEQGGA  59\n"+
"\n"+
"Query  198  ISPNAIFKALQADSPHSSSGMSEVHSPGEH-SGQSQGPPTPPTTPKTDVQPGKADLKREG  256\n"+
"             +  A +K+   D  H   G        EH SGQS GPPTPPTTPKT++Q GKAD KR+G\n"+
"Sbjct  60   AAIQAHYKSAHLDHRHPGEGSPMSDGNPEHPSGQSHGPPTPPTTPKTELQSGKADPKRDG  119\n"+
"\n"+
"Query  257  RPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYT  316\n"+
"            R + EGG+ P IDF +VDIGE+S +V+SN+ETFDV E DQYLPPNGHPG    H      \n"+
"Sbjct  120  RSMGEGGK-PHIDFGNVDIGEISHEVMSNMETFDVAELDQYLPPNGHPG----HVGSYSA  174\n"+
"\n"+
"Query  317  GSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQ  376\n"+
"              YG+ S  A  AS    W+SK     PP    P   P+                     \n"+
"Sbjct  175  AGYGLGSALAV-ASGHSAWISK-----PPGVALPTVSPS---------------------  207\n"+
"\n"+
"Query  377  PQAHTLTTLSSEPGQSQRTHIKTEQLSPS---HYSEQQQHSPQQIAYSPFNLPHYSPSYP  433\n"+
"                         G   +  +KTE   P    HY++Q   S  QIAY+  +LPHY  ++P\n"+
"Sbjct  208  -------------GVDAKAQVKTETAGPQGPPHYTDQP--STSQIAYTSLSLPHYGSAFP  252\n"+
"\n"+
"Query  434  PITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTH  493\n"+
"             I+R Q+DY+DHQ S  YY H +GQ +GLYS F+YM P+QRP+YT I+D S  PS PQ+H\n"+
"Sbjct  253  SISRPQFDYSDHQPSGPYYGH-SGQTSGLYSAFSYMGPSQRPLYTAISDPS--PSGPQSH  309\n"+
"\n"+
"Query  494  SPQHWEQPVYTQLTRP  509\n"+
"            SP HWEQPVYT L+RP\n"+
"Sbjct  310  SPTHWEQPVYTTLSRP  325\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_003961594.1<a name=XP_003961594></a> PREDICTED: transcription factor SOX-8 isoform X1 [Takifugu rubripes] \n"+
" \n"+
"Length=461\n"+
"\n"+
" Score = 288 bits (737),  Expect = 3e-89, Method: Compositional matrix adjust.\n"+
" Identities = 204/456 (45%), Positives = 256/456 (56%), Gaps = 54/456 (12%)\n"+
"\n"+
"Query  64   SEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKL  123\n"+
"            S ED+FPVCIR+AVSQVLKGYDW+LV +        KNKPHVKRPMNAFMVWAQAAR+KL\n"+
"Sbjct  50   SAEDRFPVCIRDAVSQVLKGYDWSLVAVSAPGERGLKNKPHVKRPMNAFMVWAQAARKKL  109\n"+
"\n"+
"Query  124  ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ADQYPHLHNAELSKTLGKLWRLL E+EKRPF+EEA+RLR+QHKK +PDYKYQPRRRK  K\n"+
"Sbjct  110  ADQYPHLHNAELSKTLGKLWRLLTETEKRPFIEEADRLRMQHKKTYPDYKYQPRRRKVTK  169\n"+
"\n"+
"Query  184  NGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHS--PGEHSGQSQGPPTPPTTP  241\n"+
"             G+ +      Q           ++  S        EVHS    + +GQS GPPTPP+TP\n"+
"Sbjct  170  VGEGDCRPGPTQQQDGLCKTETTMKLPS------AGEVHSYYHQDRAGQSNGPPTPPSTP  223\n"+
"\n"+
"Query  242  KTDVQPGKADLKREGRPLPEGGRQPP-----IDFRDVDIGELSSDVISNIETFDVNEFDQ  296\n"+
"            KTD   G    KRE     +GG  PP     IDF +VDI +LS+DVI  I+ FDV+EFDQ\n"+
"Sbjct  224  KTD---GHMGTKREVHRPSDGGSIPPTSRQNIDFSNVDISDLSTDVIGTIDGFDVHEFDQ  280\n"+
"\n"+
"Query  297  YLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAP  356\n"+
"            YL PN H                   STA  P+  GH +++           PP A   P\n"+
"Sbjct  281  YLTPNSH------------------GSTALPPSDTGHGYLN-----------PPGAFILP  311\n"+
"\n"+
"Query  357  QAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQH--S  414\n"+
"                   + P     +P             SE   +++  +KTEQ+SP H+S        \n"+
"Sbjct  312  NI--HSHSIPTWTRKSPALTGMPSCDKPTLSEDTTTRKPLVKTEQMSPDHHSGSCTSPPP  369\n"+
"\n"+
"Query  415  PQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQR  474\n"+
"            P Q   +P +    S +  P +    DY+D Q SSS++S  +G    LY    Y +P+  \n"+
"Sbjct  370  PLQPQCTPGSSVCPSSASSPSSTRPPDYSDLQ-SSSFFSAISGYVPPLYQ-HPYFHPSCV  427\n"+
"\n"+
"Query  475  PMYTPIADTSGVPSIPQTHS-PQHWEQPVYTQLTRP  509\n"+
"               TP+ ++  +   P +HS P  WEQP+YT LT+P\n"+
"Sbjct  428  SYATPLINSLAL--APPSHSPPSGWEQPIYTTLTKP  461\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_001020636.1<a name=NP_001020636></a> transcription factor SOX-8 [Danio rerio]\n"+
" AAX73357.1<a name=AAX73357></a> Sox8 [Danio rerio]\n"+
" AAH99993.1<a name=AAH99993></a> SRY-box containing gene 8 [Danio rerio]  \n"+
"Length=358\n"+
"\n"+
" Score = 282 bits (722),  Expect = 2e-88, Method: Compositional matrix adjust.\n"+
" Identities = 163/290 (56%), Positives = 186/290 (64%), Gaps = 34/290 (12%)\n"+
"\n"+
"Query  10   MTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKF  69\n"+
"            M++E+EK      SPT    S  S CP    SD   +         G+   + E E+ +F\n"+
"Sbjct  1    MSEEREK----CSSPT---GSCSSECPDECDSDPSCSPAGPAALRMGQ---QAEDEDGRF  50\n"+
"\n"+
"Query  70   PVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPH  129\n"+
"            PVCIR+AVSQVLKGYDW+LVPMPVRV+GS K+KPHVKRPMNAFMVWAQAARRKLADQYPH\n"+
"Sbjct  51   PVCIRDAVSQVLKGYDWSLVPMPVRVSGSGKSKPHVKRPMNAFMVWAQAARRKLADQYPH  110\n"+
"\n"+
"Query  130  LHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEA  189\n"+
"            LHNAELSKTLGKLWRLL ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK G AE+\n"+
"Sbjct  111  LHNAELSKTLGKLWRLLTESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKPGHAES  170\n"+
"\n"+
"Query  190  EEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGK  249\n"+
"            E  +E        ++KA                 PG   G+  G P   T          \n"+
"Sbjct  171  EAGSELM----QHMYKA----------------EPG--MGRLTGSPDHITDHTGHTHGPP  208\n"+
"\n"+
"Query  250  ADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLP  299\n"+
"                      P+  +Q  IDF +VDI ELS+DVI N+ TFD+ EFDQYLP\n"+
"Sbjct  209  TPPTTPKTEHPQAPKQ-NIDFSNVDISELSTDVIGNL-TFDLQEFDQYLP  256\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002595614.1<a name=XP_002595614></a> hypothetical protein BRAFLDRAFT_200721 [Branchiostoma floridae]\n"+
" EEN51626.1<a name=EEN51626></a> hypothetical protein BRAFLDRAFT_200721, partial [Branchiostoma \n"+
"floridae]  \n"+
"Length=233\n"+
"\n"+
" Score = 270 bits (691),  Expect = 2e-85, Method: Compositional matrix adjust.\n"+
" Identities = 161/239 (67%), Positives = 178/239 (74%), Gaps = 27/239 (11%)\n"+
"\n"+
"Query  84   YDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLW  143\n"+
"            YDWTLVPMPVRVNGSSK+KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLW\n"+
"Sbjct  1    YDWTLVPMPVRVNGSSKSKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLW  60\n"+
"\n"+
"Query  144  RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNG-QAEAEEA-TEQTHISPN  201\n"+
"            R+LNE EKRPF+EEAERLRVQHKKDHPDYKYQPRRRK+ K G Q   +EA +E + IS N\n"+
"Sbjct  61   RMLNEDEKRPFIEEAERLRVQHKKDHPDYKYQPRRRKNSKQGNQGSGDEAGSEASPISAN  120\n"+
"\n"+
"Query  202  AIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTD--VQPGKAD-LKRE--G  256\n"+
"             IFKALQA+SP      SE HSP +  G SQ PPTPPTTPK D  +   KAD +KR+   \n"+
"Sbjct  121  TIFKALQAESPTG----SEPHSPEDLKGPSQAPPTPPTTPKQDQGMTALKADGMKRDSTS  176\n"+
"\n"+
"Query  257  RPLPEGGRQPP--------------IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPN  301\n"+
"              L    R  P              IDF +VDIG L  DV+S++E+FDV EFDQYLPPN\n"+
"Sbjct  177  NTLTAIHRDGPHHHHHHPQGHGHPNIDFSNVDIGPL--DVMSSMESFDVEEFDQYLPPN  233\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006220134.1<a name=XP_006220134></a> PREDICTED: transcription factor SOX-9, partial [Vicugna pacos] \n"+
" \n"+
"Length=125\n"+
"\n"+
" Score = 265 bits (678),  Expect = 4e-85, Method: Compositional matrix adjust.\n"+
" Identities = 125/125 (100%), Positives = 125/125 (100%), Gaps = 0/125 (0%)\n"+
"\n"+
"Query  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"            MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL\n"+
"Sbjct  1    MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"\n"+
"Query  121  RKLAD  125\n"+
"            RKLAD\n"+
"Sbjct  121  RKLAD  125\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACN58719.1<a name=ACN58719></a> Transcription factor SOX-9, partial [Salmo salar]  \n"+
"Length=224\n"+
"\n"+
" Score = 267 bits (683),  Expect = 2e-84, Method: Compositional matrix adjust.\n"+
" Identities = 155/260 (60%), Positives = 181/260 (70%), Gaps = 50/260 (19%)\n"+
"\n"+
"Query  264  RQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP-ATHGQVTYTGSYGIS  322\n"+
"            RQ  IDFRDVDIGELSSDVIS+IETFDVNEFDQYLPPNGHPG P    GQV+YTG+YGIS\n"+
"Sbjct  1    RQLNIDFRDVDIGELSSDVISHIETFDVNEFDQYLPPNGHPGAPGGATGQVSYTGTYGIS  60\n"+
"\n"+
"Query  323  STAATPASA---GHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQA  379\n"+
"            S+  + A+    GH WM+K Q                                     Q \n"+
"Sbjct  61   SSVVSQAAGGATGHSWMTKSQQ------------------------------------QQ  84\n"+
"\n"+
"Query  380  HTLTTLSS--EPGQSQR--THIKTEQLSPSHYSEQQQHS-PQQIAYSPFNLPHY-SPSYP  433\n"+
"            H+LTTL +  E GQ+QR  THIKTEQLSPSHY++QQ  S PQ + Y  FNL H+ S SYP\n"+
"Sbjct  85   HSLTTLGNGGEQGQNQRTPTHIKTEQLSPSHYNDQQSSSPPQHVNYGSFNLQHFSSSSYP  144\n"+
"\n"+
"Query  434  PITRSQYDYTDHQ-NSSSYYSHAA-GQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQ  491\n"+
"             ITR QYD++DHQ  ++SYYSHAA GQG+GLYS  +YM+P+QRPMYTPIADT+GVPS+PQ\n"+
"Sbjct  145  SITRGQYDFSDHQGGTNSYYSHAAGGQGSGLYSFSSYMSPSQRPMYTPIADTTGVPSVPQ  204\n"+
"\n"+
"Query  492  THSPQ-HWE-QPVYTQLTRP  509\n"+
"            THSPQ HW+ QPVYTQL+RP\n"+
"Sbjct  205  THSPQHHWDQQPVYTQLSRP  224\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012724684.1<a name=XP_012724684></a> PREDICTED: transcription factor SOX-8 [Fundulus heteroclitus] \n"+
" \n"+
"Length=468\n"+
"\n"+
" Score = 275 bits (703),  Expect = 3e-84, Method: Compositional matrix adjust.\n"+
" Identities = 200/462 (43%), Positives = 248/462 (54%), Gaps = 66/462 (14%)\n"+
"\n"+
"Query  64   SEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKL  123\n"+
"            +E+++FP CIR+AVSQVLKGYDW+LVPMP +     K+KPHVKRPMNAFMVWAQAARRKL\n"+
"Sbjct  57   AEDERFPACIRDAVSQVLKGYDWSLVPMPSQGERGLKSKPHVKRPMNAFMVWAQAARRKL  116\n"+
"\n"+
"Query  124  ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ADQYPHLHNAELSKTLGKLWRLL+E+E+RPFVEEAERLR+QHK+D+PDYKYQPRRRKS K\n"+
"Sbjct  117  ADQYPHLHNAELSKTLGKLWRLLSETERRPFVEEAERLRLQHKRDYPDYKYQPRRRKSAK  176\n"+
"\n"+
"Query  184  NGQAE-------AEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPT  236\n"+
"             GQ +            +Q     N  +K        +  G +  H   +  G   GPPT\n"+
"Sbjct  177  AGQGDPTARLVQQHHHQQQQPEHQNDFYKMEAGLGRLAGIGEAPKHCHPDRPGHPHGPPT  236\n"+
"\n"+
"Query  237  PPTTPKTDVQPGKADLKREG-RPLPEGGRQPP---IDFRDVDIGELSSDVISNIETFDVN  292\n"+
"            PPTTPK+++ PG    K E  RP+       P   IDF +VDI ELS+DVI  ++ FDV \n"+
"Sbjct  237  PPTTPKSELHPGN---KHEAQRPISSSSAIHPNRNIDFSNVDISELSTDVIGTMDGFDVR  293\n"+
"\n"+
"Query  293  EFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQA  352\n"+
"            E DQYLPP+GH                     AA  A                 Q  P +\n"+
"Sbjct  294  ELDQYLPPSGH--------------------AAALLA-----------------QIEPNS  316\n"+
"\n"+
"Query  353  PPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHY----S  408\n"+
"            PP P  P   +AA          +     L   + E G  ++  IKTEQ+SP       +\n"+
"Sbjct  317  PPGPYVPQSDRAA-----GDSVVKMSDGMLAETAREDG-GRKPKIKTEQMSPGQCSSSST  370\n"+
"\n"+
"Query  409  EQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTY  468\n"+
"                H PQ  +      P  +           DY D Q S S YS   G    LY  + Y\n"+
"Sbjct  371  PPPSHQPQYASLGSGVCPSSTSPSSTSPPDPPDYADLQ-SPSVYSAFPGYPASLYQ-YPY  428\n"+
"\n"+
"Query  469  MNPAQRPMYTPIADTSGVPSIPQTHS-PQHWEQPVYTQLTRP  509\n"+
"             + ++R   TP+ ++  +   P  HS P  WEQPVY  L+RP\n"+
"Sbjct  429  FHSSRRSYATPLINSLAL--APPPHSPPSVWEQPVYATLSRP  468\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002737877.2<a name=XP_002737877></a> PREDICTED: transcription factor Sox-9-like [Saccoglossus kowalevskii] \n"+
" \n"+
"Length=465\n"+
"\n"+
" Score = 273 bits (699),  Expect = 1e-83, Method: Compositional matrix adjust.\n"+
" Identities = 156/251 (62%), Positives = 185/251 (74%), Gaps = 14/251 (6%)\n"+
"\n"+
"Query  68   KFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQY  127\n"+
"            K P  IR+AVS+VLKGYDWTLVPMPVR +  SK KPHVKRPMNAFMVWAQAAR+KLADQY\n"+
"Sbjct  54   KLPDNIRDAVSEVLKGYDWTLVPMPVRNSSGSKPKPHVKRPMNAFMVWAQAARKKLADQY  113\n"+
"\n"+
"Query  128  PHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQA  187\n"+
"            PHLHNAELSKTLGKLWR+L++ EK+PFV+EAERLR+QHKKDHPDYKYQPRRRK+VKNGQ \n"+
"Sbjct  114  PHLHNAELSKTLGKLWRMLSDKEKKPFVDEAERLRMQHKKDHPDYKYQPRRRKNVKNGQQ  173\n"+
"\n"+
"Query  188  E-AEEATEQTH-ISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDV  245\n"+
"              +EE+   T  I  +  FK LQ +   +S G  E HS    S  +  PPTPPTTPKT+ \n"+
"Sbjct  174  NGSEESGNATSPIPSSGFFKVLQRE---NSPGKQE-HSTSGSSTTAHSPPTPPTTPKTEN  229\n"+
"\n"+
"Query  246  QPGKADLKREGRPLPE-------GGRQPP-IDFRDVDIGELSSDVISNIETFDVNEFDQY  297\n"+
"                A+ +  G PL +       GG Q P IDF  VDI ELS++V+  +E+FDV EF+QY\n"+
"Sbjct  230  SSNSAENREHGPPLKKMKMSNRSGGDQDPQIDFNGVDIRELSTEVMGTMESFDVTEFEQY  289\n"+
"\n"+
"Query  298  LPPNGHPGVPA  308\n"+
"            LPPN +P + A\n"+
"Sbjct  290  LPPNSNPHLNA  300\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012407034.1<a name=XP_012407034></a> PREDICTED: transcription factor SOX-10 [Sarcophilus harrisii] \n"+
" \n"+
"Length=537\n"+
"\n"+
" Score = 275 bits (704),  Expect = 2e-83, Method: Compositional matrix adjust.\n"+
" Identities = 186/375 (50%), Positives = 225/375 (60%), Gaps = 56/375 (15%)\n"+
"\n"+
"Query  143  WRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISP--  200\n"+
"            + LLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRR   KNG+A + E        P  \n"+
"Sbjct  211  YGLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRR---KNGKAASGEGEAPGEGEPGG  267\n"+
"\n"+
"Query  201  ----NAIFKALQADSPHSSSG--MSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKR  254\n"+
"                 A +K    D  H   G  MS+  +P   SGQS GPPTPPTTPKT++Q  KA+ KR\n"+
"Sbjct  268  AAASRAHYKNSHLDHRHPGEGSPMSD-GNPEHSSGQSHGPPTPPTTPKTELQSSKAESKR  326\n"+
"\n"+
"Query  255  EGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVT  314\n"+
"            +GR L E G+ P IDF  +DIGE+S +V+SN+ETFDV EFDQYLPPNGH G P   G   \n"+
"Sbjct  327  DGRSLGESGK-PHIDFGTMDIGEISHEVMSNMETFDVAEFDQYLPPNGHAGHPGHVGGYA  385\n"+
"\n"+
"Query  315  YTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPP  374\n"+
"              G YG+ S  A  AS    W+SK    PP    P  +PP   A                \n"+
"Sbjct  386  AAG-YGLGSALAV-ASGHSAWISK----PPGVALPAASPPGVDA----------------  423\n"+
"\n"+
"Query  375  QQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPP  434\n"+
"               +A   T  S  PG             P HY+EQ   S  QIAY+  +LPHY  ++P \n"+
"Sbjct  424  ---KAQGKTEASGPPG-------------PPHYAEQP--STSQIAYTSLSLPHYGSAFPS  465\n"+
"\n"+
"Query  435  ITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHS  494\n"+
"            I+R Q+DY+DHQ S  YY H +GQ +GLYS F+YM P+QRP+YT I+D S  PS PQ+HS\n"+
"Sbjct  466  ISRPQFDYSDHQPSGPYYGH-SGQASGLYSAFSYMGPSQRPLYTAISDPS--PSGPQSHS  522\n"+
"\n"+
"Query  495  PQHWEQPVYTQLTRP  509\n"+
"            P HWEQPVYT L+RP\n"+
"Sbjct  523  PTHWEQPVYTTLSRP  537\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014677044.1<a name=XP_014677044></a> PREDICTED: transcription factor SOX-9-like [Priapulus caudatus] \n"+
" \n"+
"Length=462\n"+
"\n"+
" Score = 273 bits (698),  Expect = 2e-83, Method: Compositional matrix adjust.\n"+
" Identities = 195/475 (41%), Positives = 254/475 (53%), Gaps = 71/475 (15%)\n"+
"\n"+
"Query  4    LDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKE  63\n"+
"            +D  M   DEQ K     PS  +S         +GS +D ++      T P   P+ K  \n"+
"Sbjct  1    MDLTMSDKDEQVK----TPSSVLSH--------TGSDTDLDSDTGTSGTSPSSNPEKKSR  48\n"+
"\n"+
"Query  64   S----------EEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFM  113\n"+
"            S          ++ + P  IR+AVS VLKGYDWTLVPMP R  GS K +PHVKRPMNAFM\n"+
"Sbjct  49   SAAAAAAAGLIDDREMPPSIRDAVSNVLKGYDWTLVPMPCRPTGSEKRRPHVKRPMNAFM  108\n"+
"\n"+
"Query  114  VWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYK  173\n"+
"            VWAQAARRKLADQYPHLHNAELSKTLGKLWRLL++ EK+PF+EEAERLRV HKK+HPDYK\n"+
"Sbjct  109  VWAQAARRKLADQYPHLHNAELSKTLGKLWRLLSDGEKKPFIEEAERLRVVHKKEHPDYK  168\n"+
"\n"+
"Query  174  YQPRRRKSVKNGQ-AEAEEATEQTHISPNAIFKALQ-ADSPHSSSGMSEVHSPGE---HS  228\n"+
"            YQPRRRK +K  Q  + EEA++  H S   +FKAL+ ++   +SSG S     GE   H \n"+
"Sbjct  169  YQPRRRKPLKGAQPNQQEEASQVNHSSNAVLFKALKSSEKETASSGNS-----GEMAVHK  223\n"+
"\n"+
"Query  229  GQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIET  288\n"+
"            GQ    P        +       LK   R    GG QP +D+  VD+  L++DV+SNIE \n"+
"Sbjct  224  GQGPPTPPTTPNGTKE-----GALKHTRR----GGHQPSLDYNQVDMASLTTDVMSNIEH  274\n"+
"\n"+
"Query  289  FDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQ  348\n"+
"             D +EFDQYL PNG P     H    Y  +YG +S+   P S+    ++K      P  +\n"+
"Sbjct  275  IDQSEFDQYL-PNGQPN---PHMLAHYPLNYGSASSGMPPHSSWPASLAKYGLTRSPSDR  330\n"+
"\n"+
"Query  349  PPQAPPA--PQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTH-------IKT  399\n"+
"            P     A   Q      +      AAPP        T++  E   + R H       +K \n"+
"Sbjct  331  PSATTVATTTQESVYINSNSYSSAAAPP--------TSVVGEATSATRFHELQPASSVKL  382\n"+
"\n"+
"Query  400  EQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPS-YPPITRSQYDYTDHQNSSSYYS  453\n"+
"            E L+    + ++       +  P+ +P   P  YP +T+++Y+Y      SS+YS\n"+
"Sbjct  383  EHLT----AVRRVGDVGGFSRDPYEMPQ--PGLYPAVTQAEYEYIPQ--GSSFYS  429\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015391817.1<a name=XP_015391817></a> PREDICTED: transcription factor SOX-10 [Panthera tigris altaica] \n"+
" \n"+
"Length=459\n"+
"\n"+
" Score = 272 bits (696),  Expect = 3e-83, Method: Compositional matrix adjust.\n"+
" Identities = 178/365 (49%), Positives = 218/365 (60%), Gaps = 58/365 (16%)\n"+
"\n"+
"Query  144  RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAE----EATEQTHIS  199\n"+
"            RLLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+ K  Q E+E    EA +    +\n"+
"Sbjct  73   RLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKNGKAAQGESECPGGEAEQGGAAA  132\n"+
"\n"+
"Query  200  PNAIFKALQADSPHSSSGMSEVHSPGEH-SGQSQGPPTPPTTPKTDVQPGKADLKREGRP  258\n"+
"              A +K+   D  H   G        EH SGQS GPPTPPTTPKT++Q GKAD KR+GR \n"+
"Sbjct  133  IQAHYKSAHLDHRHPGEGSPMSDGNPEHPSGQSHGPPTPPTTPKTELQSGKADPKRDGRS  192\n"+
"\n"+
"Query  259  LPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGS  318\n"+
"            + EGG+ P IDF +VDIGE+S +V+SN+ETFDV E DQYLPPNGHPG    H        \n"+
"Sbjct  193  MGEGGK-PHIDFGNVDIGEISHEVMSNMETFDVAELDQYLPPNGHPG----HVGGYSAAG  247\n"+
"\n"+
"Query  319  YGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQ  378\n"+
"            YG+ S  A  AS    W+SK                                      P \n"+
"Sbjct  248  YGLGSALAV-ASGHSAWISK--------------------------------------PP  268\n"+
"\n"+
"Query  379  AHTLTTLSSEPGQSQRTHIKTEQLSPS---HYSEQQQHSPQQIAYSPFNLPHYSPSYPPI  435\n"+
"               L T+S  PG   +  +KTE   P    HY++Q   S  QIAY+  +LPHY  ++P I\n"+
"Sbjct  269  GVALPTVSP-PGVDAKAQVKTETAGPQGPPHYTDQP--STSQIAYTSLSLPHYGSAFPSI  325\n"+
"\n"+
"Query  436  TRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP  495\n"+
"            +R Q+DY+DHQ S  YY H +GQ +GLYS F+YM P+QRP+YT I+D S  PS PQ+HSP\n"+
"Sbjct  326  SRPQFDYSDHQPSGPYYGH-SGQASGLYSAFSYMGPSQRPLYTAISDPS--PSGPQSHSP  382\n"+
"\n"+
"Query  496  QHWEQ  500\n"+
"             HWEQ\n"+
"Sbjct  383  THWEQ  387\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AFJ05115.1<a name=AFJ05115></a> transcription factor SOX-9, partial [Taeniopygia guttata]  \n"+
"Length=200\n"+
"\n"+
" Score = 261 bits (666),  Expect = 3e-82, Method: Compositional matrix adjust.\n"+
" Identities = 169/241 (70%), Positives = 172/241 (71%), Gaps = 42/241 (17%)\n"+
"\n"+
"Query  173  KYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQ  232\n"+
"            KYQPRRRKSVKNGQAE EE  EQTHISPNAIFKALQADSP SSS +SEVHSPGEHSGQSQ\n"+
"Sbjct  1    KYQPRRRKSVKNGQAEQEEGAEQTHISPNAIFKALQADSPQSSSSISEVHSPGEHSGQSQ  60\n"+
"\n"+
"Query  233  GPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPP-IDFRDVDIGELSSDVISNIETFDV  291\n"+
"            GPPTPPTTPKTD QPGK DLKRE R L EGGRQPP IDFRDVDIGELSSDVISNIETFDV\n"+
"Sbjct  61   GPPTPPTTPKTDPQPGKQDLKREARALGEGGRQPPHIDFRDVDIGELSSDVISNIETFDV  120\n"+
"\n"+
"Query  292  NEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQ  351\n"+
"            NEFDQYLPPNGHPG P   GQVTYTGSYGIS  A TPA    VWM+KQQ P    +Q PQ\n"+
"Sbjct  121  NEFDQYLPPNGHPGQP---GQVTYTGSYGISGAAGTPAG---VWMAKQQQPALGTEQGPQ  174\n"+
"\n"+
"Query  352  APPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQ  411\n"+
"                                                     QRTHIKTEQLSPSHYSEQQ\n"+
"Sbjct  175  QQQQQ-----------------------------------QQRTHIKTEQLSPSHYSEQQ  199\n"+
"\n"+
"Query  412  Q  412\n"+
"            Q\n"+
"Sbjct  200  Q  200\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KPP70379.1<a name=KPP70379></a> transcription factor Sox-9-A-like [Scleropages formosus]  \n"+
"Length=331\n"+
"\n"+
" Score = 264 bits (674),  Expect = 1e-81, Method: Compositional matrix adjust.\n"+
" Identities = 146/168 (87%), Positives = 148/168 (88%), Gaps = 6/168 (4%)\n"+
"\n"+
"Query  144  RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAI  203\n"+
"            RLLNE EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQ EAEE+ EQTHISPNAI\n"+
"Sbjct  13   RLLNEVEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQGEAEESAEQTHISPNAI  72\n"+
"\n"+
"Query  204  FKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPE-  261\n"+
"            FKAL QADSP SS  M EVHSPGEHSGQSQGPPTPPTTPKTDVQ GK DLKREGRPL E \n"+
"Sbjct  73   FKALQQADSPASS--MGEVHSPGEHSGQSQGPPTPPTTPKTDVQAGKVDLKREGRPLQES  130\n"+
"\n"+
"Query  262  GGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPAT  309\n"+
"             GRQ  IDFRDVDIGELSSDVIS+IETFDV EFDQYLPPNG   VP T\n"+
"Sbjct  131  AGRQLNIDFRDVDIGELSSDVISHIETFDVAEFDQYLPPNG--AVPYT  176\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009886858.1<a name=XP_009886858></a> PREDICTED: transcription factor SOX-8, partial [Charadrius vociferus] \n"+
" \n"+
"Length=338\n"+
"\n"+
" Score = 263 bits (671),  Expect = 4e-81, Method: Compositional matrix adjust.\n"+
" Identities = 125/168 (74%), Positives = 143/168 (85%), Gaps = 5/168 (3%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLAD  125\n"+
"            +++FP CIR+AVSQVLKGYDW+LVPMPVR NGS K KPHVKRPMNAFMVWAQAARRKLAD\n"+
"Sbjct  15   DERFPACIRDAVSQVLKGYDWSLVPMPVRGNGSLKAKPHVKRPMNAFMVWAQAARRKLAD  74\n"+
"\n"+
"Query  126  QYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNG  185\n"+
"            QYPHLHNAELSKTLGKLWRLL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK G\n"+
"Sbjct  75   QYPHLHNAELSKTLGKLWRLLSENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKAG  134\n"+
"\n"+
"Query  186  QAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQG  233\n"+
"            Q++++   E +H +   I+K   ADS     GM+E H  G+H+GQ+ G\n"+
"Sbjct  135  QSDSDSGAELSHHAGTQIYK---ADS--GLGGMAESHHHGDHTGQTHG  177\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017509598.1<a name=XP_017509598></a> PREDICTED: transcription factor SOX-9-like [Manis javanica]  \n"+
"\n"+
"Length=273\n"+
"\n"+
" Score = 257 bits (657),  Expect = 7e-80, Method: Compositional matrix adjust.\n"+
" Identities = 126/130 (97%), Positives = 128/130 (98%), Gaps = 1/130 (1%)\n"+
"\n"+
"Query  380  HTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQ  439\n"+
"            HTLTTLSSEPGQ+QRTHIKTEQLSPSHYSEQQ HSPQQIAYSPFNLPHYSPSYPPITRSQ\n"+
"Sbjct  145  HTLTTLSSEPGQAQRTHIKTEQLSPSHYSEQQ-HSPQQIAYSPFNLPHYSPSYPPITRSQ  203\n"+
"\n"+
"Query  440  YDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWE  499\n"+
"            YDYTDHQNS SYYSHAAGQG+GLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWE\n"+
"Sbjct  204  YDYTDHQNSGSYYSHAAGQGSGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWE  263\n"+
"\n"+
"Query  500  QPVYTQLTRP  509\n"+
"            QPVYTQLTRP\n"+
"Sbjct  264  QPVYTQLTRP  273\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_004063516.1<a name=XP_004063516></a> PREDICTED: transcription factor SOX-10, partial [Gorilla gorilla \n"+
"gorilla]  \n"+
"Length=263\n"+
"\n"+
" Score = 255 bits (652),  Expect = 3e-79, Method: Compositional matrix adjust.\n"+
" Identities = 128/181 (71%), Positives = 142/181 (78%), Gaps = 14/181 (8%)\n"+
"\n"+
"Query  63   ESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRK  122\n"+
"            E+++DKFPVCIREAVSQVL GYDWTLVPMPVRVNG+SK+KPHVKRPMNAFMVWAQAARRK\n"+
"Sbjct  90   EADDDKFPVCIREAVSQVLSGYDWTLVPMPVRVNGASKSKPHVKRPMNAFMVWAQAARRK  149\n"+
"\n"+
"Query  123  LADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSV  182\n"+
"            LADQYPHLHNAELSKTLGKLWRLLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+ \n"+
"Sbjct  150  LADQYPHLHNAELSKTLGKLWRLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKNG  209\n"+
"\n"+
"Query  183  KNGQAEAE----EATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPP  238\n"+
"            K  Q EAE    EA +    +  A +K+   D  H          PGE S  S G P  P\n"+
"Sbjct  210  KAAQGEAECPGGEAEQGGTAAIQAHYKSAHLDHRH----------PGEGSPMSDGNPEHP  259\n"+
"\n"+
"Query  239  T  239\n"+
"            +\n"+
"Sbjct  260  S  260\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015819190.1<a name=XP_015819190></a> PREDICTED: transcription factor SOX-8 [Nothobranchius furzeri] \n"+
" \n"+
"Length=441\n"+
"\n"+
" Score = 260 bits (665),  Expect = 9e-79, Method: Compositional matrix adjust.\n"+
" Identities = 150/239 (63%), Positives = 174/239 (73%), Gaps = 16/239 (7%)\n"+
"\n"+
"Query  65   EEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLA  124\n"+
"            E+++FP CIR+AVSQVLKGYDW+LVP+P +     K++PHVKRPMNAFMVWAQAARRKLA\n"+
"Sbjct  56   EDERFPACIRDAVSQVLKGYDWSLVPVPGQGARGLKSRPHVKRPMNAFMVWAQAARRKLA  115\n"+
"\n"+
"Query  125  DQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            DQYPHLHNAELSKTLGKLWRLL+ESE+RPFVEEAERLR QHKK++PDYKYQPRRRKS K \n"+
"Sbjct  116  DQYPHLHNAELSKTLGKLWRLLSESERRPFVEEAERLRTQHKKNYPDYKYQPRRRKSCKP  175\n"+
"\n"+
"Query  185  GQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTD  244\n"+
"            G+ +      Q      A +K     + H            +  GQ  GPPTPPTTPKTD\n"+
"Sbjct  176  GEGDPGPGLVQQQ---QAFYKMEPGPATHP-----------DRPGQPHGPPTPPTTPKTD  221\n"+
"\n"+
"Query  245  VQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGH  303\n"+
"            + PG A L+R   P P   RQ  IDF +VDI ELSSDVI  ++ FDV+E DQYLPPN H\n"+
"Sbjct  222  LHPG-AKLQRSSVPAPLPSRQ-NIDFSNVDISELSSDVIGTMDGFDVHELDQYLPPNSH  278\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACZ54382.1<a name=ACZ54382></a> SRY-box 10 protein, partial [Monodelphis domestica]  \n"+
"Length=192\n"+
"\n"+
" Score = 251 bits (641),  Expect = 1e-78, Method: Compositional matrix adjust.\n"+
" Identities = 137/187 (73%), Positives = 150/187 (80%), Gaps = 6/187 (3%)\n"+
"\n"+
"Query  63   ESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRK  122\n"+
"            E+++DKFPVCIREAVSQVL GYDWTLVPMPVRVNGSSK+KPHVKRPMNAFMVWAQAARRK\n"+
"Sbjct  7    EADDDKFPVCIREAVSQVLSGYDWTLVPMPVRVNGSSKSKPHVKRPMNAFMVWAQAARRK  66\n"+
"\n"+
"Query  123  LADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSV  182\n"+
"            LADQYPHLHNAELSKTLGKLWRLLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+ \n"+
"Sbjct  67   LADQYPHLHNAELSKTLGKLWRLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKNG  126\n"+
"\n"+
"Query  183  KNGQAEAEEATEQTHISPNAI---FKALQADSPHSSSG--MSEVHSPGEHSGQSQGPPTP  237\n"+
"            K    E E   +       AI   +K    D  H   G  MS+  +P   SGQS GPPTP\n"+
"Sbjct  127  KAASGEGEAPGDGEPGGAAAIQAHYKNAHLDHRHPGEGSPMSDG-NPEHSSGQSHGPPTP  185\n"+
"\n"+
"Query  238  PTTPKTD  244\n"+
"            PTTPKT+\n"+
"Sbjct  186  PTTPKTE  192\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013381128.1<a name=XP_013381128></a> PREDICTED: transcription factor Sox-10-like [Lingula anatina] \n"+
" \n"+
"Length=306\n"+
"\n"+
" Score = 254 bits (650),  Expect = 3e-78, Method: Compositional matrix adjust.\n"+
" Identities = 150/278 (54%), Positives = 177/278 (64%), Gaps = 34/278 (12%)\n"+
"\n"+
"Query  68   KFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQY  127\n"+
"            +FP  I++AV+ VLKGYDWTLVPM  R   S K KPH+KRPMNAFMVWAQAAR+KLADQY\n"+
"Sbjct  44   EFPSEIQQAVAHVLKGYDWTLVPMSTRAGASEKRKPHIKRPMNAFMVWAQAARKKLADQY  103\n"+
"\n"+
"Query  128  PHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQA  187\n"+
"            PHLHNAELSKTLGKLWR+L E EKRPF++EAERLR +HK DHP+YKYQPRRRK++K+   \n"+
"Sbjct  104  PHLHNAELSKTLGKLWRMLGEGEKRPFMDEAERLRQKHKNDHPEYKYQPRRRKNIKS--V  161\n"+
"\n"+
"Query  188  EAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPP-----TPPTTPK  242\n"+
"              E +T+Q   S  A  +++    P  S G S+  S    +  S+  P     TPPTTP \n"+
"Sbjct  162  SGETSTQQ---SKAAFLRSI--SEPARSPGCSDDDSCMMSANSSRNLPNHQSLTPPTTP-  215\n"+
"\n"+
"Query  243  TDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPN-  301\n"+
"                  +A + +  R     G Q PIDF  VDIGEL  DVI NIE FD  E DQYLPPN \n"+
"Sbjct  216  ------QALMTKPLRHFSGPGGQ-PIDFSRVDIGELREDVIGNIEHFDETELDQYLPPNR  268\n"+
"\n"+
"Query  302  --------GHP----GVPATHGQVTYTGSYGISSTAAT  327\n"+
"                    G P    GV A +   TY+G  G SS A T\n"+
"Sbjct  269  QLNGRHLVGQPQMINGVSAHNPPATYSGGPG-SSAAGT  305\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009895648.1<a name=XP_009895648></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-8 [Picoides \n"+
"pubescens]  \n"+
"Length=262\n"+
"\n"+
" Score = 252 bits (644),  Expect = 4e-78, Method: Compositional matrix adjust.\n"+
" Identities = 139/239 (58%), Positives = 165/239 (69%), Gaps = 17/239 (7%)\n"+
"\n"+
"Query  7    FMKMTDEQEKGLSGAPSPT-----MSEDSAGSPCP-SGSGSDTENTRPQENTFPKGEPDL  60\n"+
"             + MT+E +K L    SPT     MS   + S  P S +GS+     P     P G   L\n"+
"Sbjct  1    MLNMTEEHDKALEAPCSPTGTTSSMSHVDSDSDSPLSAAGSEGLGCAPAAAPRPPGAAPL  60\n"+
"\n"+
"Query  61   KKESE----EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWA  116\n"+
"              + +    +++FP CIR+AVSQVLKGYDW+LVPMPVR NGS K KPHVKRPMNAFMVWA\n"+
"Sbjct  61   GSKVDAAEVDERFPACIRDAVSQVLKGYDWSLVPMPVRGNGSLKAKPHVKRPMNAFMVWA  120\n"+
"\n"+
"Query  117  QAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQP  176\n"+
"            QAARRKLADQYPHLHNAELSKTLGKLWRLL+E+EKRPFVEEAERLRVQHKKDHPDYKYQP\n"+
"Sbjct  121  QAARRKLADQYPHLHNAELSKTLGKLWRLLSENEKRPFVEEAERLRVQHKKDHPDYKYQP  180\n"+
"\n"+
"Query  177  RRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPP  235\n"+
"            RRRK       +++   E +H +   I+K   ADS     GM++ H  G+H+G  +GPP\n"+
"Sbjct  181  RRRKXXXXXXXDSDSGAELSHHAGTQIYK---ADS--GLGGMADSHHHGDHAG--KGPP  232\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013381127.1<a name=XP_013381127></a> PREDICTED: transcription factor SOX-9-like [Lingula anatina] \n"+
" \n"+
"Length=475\n"+
"\n"+
" Score = 258 bits (660),  Expect = 1e-77, Method: Compositional matrix adjust.\n"+
" Identities = 156/293 (53%), Positives = 184/293 (63%), Gaps = 20/293 (7%)\n"+
"\n"+
"Query  26   MSEDSAGSPCPSGSGSDTENTRPQENTFP-------KGEPDLKKES---EEDKFPVCIRE  75\n"+
"            M   S  SP  S SG ++E     EN FP       K   D K+ S     D+    I++\n"+
"Sbjct  1    MEHASMSSPT-SDSGRESERESDSEN-FPATAKMPTKSSDDPKQSSTSNSSDELSTDIQQ  58\n"+
"\n"+
"Query  76   AVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAEL  135\n"+
"            AV+ VLKGYDW+LVPMP R  GS K KPH+KRPMNAFMVWAQAARR+LADQYPHLHNAEL\n"+
"Sbjct  59   AVASVLKGYDWSLVPMPTRGPGSDKRKPHIKRPMNAFMVWAQAARRRLADQYPHLHNAEL  118\n"+
"\n"+
"Query  136  SKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQ  195\n"+
"            SKTLGKLWR+L+E EK+PFVEEAERLR +HKKD P+YKYQPRRRK +K      E     \n"+
"Sbjct  119  SKTLGKLWRMLSEGEKKPFVEEAERLRQKHKKDFPEYKYQPRRRKPMKGASGSGESNNNN  178\n"+
"\n"+
"Query  196  THISPN-----AIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKA  250\n"+
"            ++ S +      IFK L+ D+   SS +SE  S   +    +GPPTPP TP    Q G  \n"+
"Sbjct  179  SNDSSSSLSNAVIFKTLR-DTSSPSSSISEGESCMLNGCAVRGPPTPPATPNQHEQTGTQ  237\n"+
"\n"+
"Query  251  DLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGH  303\n"+
"            +     R L   G+  PIDF  VD+GE   DVI NI+ FD  E DQYLPPNGH\n"+
"Sbjct  238  NKLAHLRHL--AGQSQPIDFSRVDLGEFRDDVIGNIDHFDEAELDQYLPPNGH  288\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AIE16096.1<a name=AIE16096></a> transcription faxtor Sox9 [Pinctada margaritifera]  \n"+
"Length=463\n"+
"\n"+
" Score = 257 bits (656),  Expect = 3e-77, Method: Compositional matrix adjust.\n"+
" Identities = 156/300 (52%), Positives = 184/300 (61%), Gaps = 17/300 (6%)\n"+
"\n"+
"Query  27   SEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLK-KESEEDKFPVCIREAVSQVLKGYD  85\n"+
"            S+DS GSPCP  S     +        P  E   K K+ E DKFP  I++AVSQVLKGYD\n"+
"Sbjct  7    SDDSRGSPCPQPSTEQLLDAVRGAGPLPPEELTGKVKQVEGDKFPKQIQDAVSQVLKGYD  66\n"+
"\n"+
"Query  86   WTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRL  145\n"+
"            W+L+PMP R     K  PH+KRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRL\n"+
"Sbjct  67   WSLIPMPQRGPNGEKRNPHIKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRL  126\n"+
"\n"+
"Query  146  LNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFK  205\n"+
"            L+E EKRPFV+EAERLRVQHKKD+PDYKYQPRRRK +KN      E     H     +FK\n"+
"Sbjct  127  LSEEEKRPFVDEAERLRVQHKKDYPDYKYQPRRRKPLKNANGSPPETNNNIH--GGMMFK  184\n"+
"\n"+
"Query  206  ALQADSPHSSSGM--SEVHSPGEHSGQSQGPPTPPTTPKTDVQPGK--ADLKREGRPLPE  261\n"+
"             +Q     S +G+   +      H+     P  P T  + D+   K  AD  R  RP P \n"+
"Sbjct  185  GMQG----SPTGISDGDSSDCSSHNNPHGPPTPPTTPNQQDLINLKSMADRMRGARP-PI  239\n"+
"\n"+
"Query  262  GGRQP-PIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYG  320\n"+
"             G QP PIDF  VD+ E+++D  +     D++EFDQYLP  G   +P  H    YT  YG\n"+
"Sbjct  240  HGHQPNPIDFSRVDLREIATDATA---FNDLDEFDQYLPTTG-SHIPGAHAPEQYTSCYG  295\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010967835.1<a name=XP_010967835></a> PREDICTED: transcription factor SOX-9, partial [Camelus bactrianus] \n"+
" \n"+
"Length=113\n"+
"\n"+
" Score = 244 bits (622),  Expect = 7e-77, Method: Compositional matrix adjust.\n"+
" Identities = 113/113 (100%), Positives = 113/113 (100%), Gaps = 0/113 (0%)\n"+
"\n"+
"Query  32   GSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPM  91\n"+
"            GSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPM\n"+
"Sbjct  1    GSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPM  60\n"+
"\n"+
"Query  92   PVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWR  144\n"+
"            PVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWR\n"+
"Sbjct  61   PVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWR  113\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014980744.1<a name=XP_014980744></a> PREDICTED: transcription factor SOX-8 [Macaca mulatta]  \n"+
"Length=339\n"+
"\n"+
" Score = 252 bits (643),  Expect = 8e-77, Method: Compositional matrix adjust.\n"+
" Identities = 123/178 (69%), Positives = 141/178 (79%), Gaps = 11/178 (6%)\n"+
"\n"+
"Query  63   ESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAAR  120\n"+
"            E+ +++FP CIR+AVSQVLKGYDW+LVPMPVR  G    K KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  133  EAADERFPACIRDAVSQVLKGYDWSLVPMPVRGGGGGALKAKPHVKRPMNAFMVWAQAAR  192\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  193  RKLADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  252\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQT-HISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTP  237\n"+
"            S K GQ++++   E   H    A++KA         SG+ + H  G+H+GQ+ G  TP\n"+
"Sbjct  253  STKAGQSDSDSGAELGPHPGGGAVYKA--------ESGLGDAHHHGDHTGQTHGAATP  302\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017923109.1<a name=XP_017923109></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-8 [Manacus \n"+
"vitellinus]  \n"+
"Length=368\n"+
"\n"+
" Score = 251 bits (642),  Expect = 3e-76, Method: Compositional matrix adjust.\n"+
" Identities = 193/413 (47%), Positives = 236/413 (57%), Gaps = 57/413 (14%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            + RPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLL+E+EKRPFVEEAERLRVQ\n"+
"Sbjct  5    LGRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLSENEKRPFVEEAERLRVQ  64\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSP  224\n"+
"            HKKDHPDYKYQPRRRKSVK GQ++++   E +H     I+K    DS     GM++ H  \n"+
"Sbjct  65   HKKDHPDYKYQPRRRKSVKAGQSDSDSGAELSHHGGTQIYK---GDS--GLGGMADPHHH  119\n"+
"\n"+
"Query  225  GEHSGQSQGPPTPPTTPKTDVQPG-KADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVI  283\n"+
"            G+H+GQ+ GPPTPPTTPKTD+  G K +LK EGR L E GRQ  IDF +VDI ELSS+VI\n"+
"Sbjct  120  GDHTGQTHGPPTPPTTPKTDLHHGSKQELKHEGRRLVESGRQ-NIDFSNVDISELSSEVI  178\n"+
"\n"+
"Query  284  SNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPP  343\n"+
"            +N+  F       Y   +      A         SYG  +    P  AG         P \n"+
"Sbjct  179  NNMXDFYARVSTSYTAASRPRAAAAASTAHGRGRSYGAVALRTRPRGAG-------GRPG  231\n"+
"\n"+
"Query  344  PPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLS  403\n"+
"               QQ P +  A                               S+PGQS   H+ TEQLS\n"+
"Sbjct  232  VDSQQAPASAVAH-----------------------------GSKPGQSTAPHL-TEQLS  261\n"+
"\n"+
"Query  404  PSHYSEQQQHSPQQIAYSPF------NLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAG  457\n"+
"            P+  + Q   SP    Y  +           + +    + SQ DYTD Q SS+YY+   G\n"+
"Sbjct  262  PAX-TRQSHGSPAHSDYGSYSAQACATTAASATAAASFSSSQCDYTDLQ-SSNYYNPYPG  319\n"+
"\n"+
"Query  458  QGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP-QHWEQPVYTQLTRP  509\n"+
"              + +Y  + Y + ++RP  TPI +  G+ SIP  HSP  +W+QPVYT LTRP\n"+
"Sbjct  320  YPSSIYQ-YPYFHSSRRPYATPILN--GL-SIPPAHSPTANWDQPVYTTLTRP  368\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAC24565.1<a name=AAC24565></a> Dominant megacolon mutant Sox-10 protein [Mus musculus]  \n"+
"Length=292\n"+
"\n"+
" Score = 248 bits (634),  Expect = 4e-76, Method: Compositional matrix adjust.\n"+
" Identities = 114/128 (89%), Positives = 123/128 (96%), Gaps = 0/128 (0%)\n"+
"\n"+
"Query  63   ESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRK  122\n"+
"            E+++DKFPVCIREAVSQVL GYDWTLVPMPVRVNG+SK+KPHVKRPMNAFMVWAQAARRK\n"+
"Sbjct  62   EADDDKFPVCIREAVSQVLSGYDWTLVPMPVRVNGASKSKPHVKRPMNAFMVWAQAARRK  121\n"+
"\n"+
"Query  123  LADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSV  182\n"+
"            LADQYPHLHNAELSKTLGKLWRLLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+ \n"+
"Sbjct  122  LADQYPHLHNAELSKTLGKLWRLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKNG  181\n"+
"\n"+
"Query  183  KNGQAEAE  190\n"+
"            K  Q EAE\n"+
"Sbjct  182  KAAQGEAE  189\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005591840.1<a name=XP_005591840></a> PREDICTED: transcription factor SOX-8 [Macaca fascicularis]  \n"+
"\n"+
"Length=303\n"+
"\n"+
" Score = 246 bits (629),  Expect = 3e-75, Method: Compositional matrix adjust.\n"+
" Identities = 120/171 (70%), Positives = 137/171 (80%), Gaps = 11/171 (6%)\n"+
"\n"+
"Query  63   ESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAAR  120\n"+
"            E+ +++FP CIR+AVSQVLKGYDW+LVPMPVR  G    K KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  58   EAADERFPACIRDAVSQVLKGYDWSLVPMPVRGGGGGALKAKPHVKRPMNAFMVWAQAAR  117\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  118  RKLADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  177\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQT-HISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQ  230\n"+
"            S K GQ++++   E   H    A++KA         SG+ + H  G+H+GQ\n"+
"Sbjct  178  STKAGQSDSDSGAELGPHAGGGAVYKA--------ESGLGDAHHHGDHTGQ  220\n"+
"\n"+
"\n"+
" Score = 49.3 bits (116),  Expect = 0.002, Method: Compositional matrix adjust.\n"+
" Identities = 32/73 (44%), Positives = 45/73 (62%), Gaps = 6/73 (8%)\n"+
"\n"+
"Query  438  SQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP-Q  496\n"+
"            +Q DY D Q +SSYY    G   GLY    + +P +RP  +P+ ++    ++P +HSP  \n"+
"Sbjct  236  AQGDYGDLQ-ASSYYGAYPGYAPGLYQYPCFHSP-RRPYASPLLNSL---ALPPSHSPTS  290\n"+
"\n"+
"Query  497  HWEQPVYTQLTRP  509\n"+
"            HW+QPVYT LTRP\n"+
"Sbjct  291  HWDQPVYTTLTRP  303\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010337512.1<a name=XP_010337512></a> PREDICTED: transcription factor SOX-8 [Saimiri boliviensis boliviensis] \n"+
" \n"+
"Length=493\n"+
"\n"+
" Score = 252 bits (644),  Expect = 3e-75, Method: Compositional matrix adjust.\n"+
" Identities = 127/196 (65%), Positives = 147/196 (75%), Gaps = 13/196 (7%)\n"+
"\n"+
"Query  63   ESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAAR  120\n"+
"            E+ +++FP CIR+AVSQVLKGYDW+LVPMPVR +G    K KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  247  EAADERFPACIRDAVSQVLKGYDWSLVPMPVRGSGGGALKAKPHVKRPMNAFMVWAQAAR  306\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  307  RKLADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  366\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQT-HISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGP--PTP  237\n"+
"            S K GQ++++   E   H    A++KA         +G+ + H  GEH+G  Q P     \n"+
"Sbjct  367  SAKAGQSDSDSGAELGPHPGSGAVYKA--------DAGLGDAHHHGEHTGGLQAPRVSAG  418\n"+
"\n"+
"Query  238  PTTPKTDVQPGKADLK  253\n"+
"            P  P T  Q   +DL+\n"+
"Sbjct  419  PCGPFTGAQGDYSDLQ  434\n"+
"\n"+
"\n"+
" Score = 54.3 bits (129),  Expect = 7e-05, Method: Compositional matrix adjust.\n"+
" Identities = 33/77 (43%), Positives = 46/77 (60%), Gaps = 6/77 (8%)\n"+
"\n"+
"Query  434  PITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTH  493\n"+
"            P T +Q DY+D Q +SSYY    G   GLY    + +P +RP  +P+ +     ++P  H\n"+
"Sbjct  422  PFTGAQGDYSDLQ-ASSYYGAYPGYAPGLYQYPCFHSP-RRPYASPLLNGL---ALPPAH  476\n"+
"\n"+
"Query  494  SP-QHWEQPVYTQLTRP  509\n"+
"            SP  HW+QP+YT LTRP\n"+
"Sbjct  477  SPTSHWDQPLYTTLTRP  493\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EDM03938.1<a name=EDM03938></a> SRY-box containing gene 8 (predicted), isoform CRA_a [Rattus \n"+
"norvegicus]  \n"+
"Length=241\n"+
"\n"+
" Score = 243 bits (621),  Expect = 7e-75, Method: Compositional matrix adjust.\n"+
" Identities = 116/170 (68%), Positives = 136/170 (80%), Gaps = 10/170 (6%)\n"+
"\n"+
"Query  63   ESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAAR  120\n"+
"            E+ +++FP CIR+AVSQVLKGYDW+LVPMPVR  G    K KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  55   EAADERFPACIRDAVSQVLKGYDWSLVPMPVRGGGGGTLKAKPHVKRPMNAFMVWAQAAR  114\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  115  RKLADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  174\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQ  230\n"+
"            SVK G+++++  TE  H     ++K        + + + + H   +H+GQ\n"+
"Sbjct  175  SVKTGRSDSDSGTELGHHPGGPMYK--------TDTVLGDAHRHSDHTGQ  216\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009083174.1<a name=XP_009083174></a> PREDICTED: transcription factor SOX-8, partial [Acanthisitta \n"+
"chloris]  \n"+
"Length=151\n"+
"\n"+
" Score = 239 bits (611),  Expect = 9e-75, Method: Compositional matrix adjust.\n"+
" Identities = 116/156 (74%), Positives = 131/156 (84%), Gaps = 5/156 (3%)\n"+
"\n"+
"Query  82   KGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGK  141\n"+
"            KGYDW+LVPMPVR NGS K KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGK\n"+
"Sbjct  1    KGYDWSLVPMPVRGNGSLKAKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGK  60\n"+
"\n"+
"Query  142  LWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPN  201\n"+
"            LW LL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK GQ++++   E +H +  \n"+
"Sbjct  61   LWSLLSENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKAGQSDSDSGAELSHHAGT  120\n"+
"\n"+
"Query  202  AIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTP  237\n"+
"             I+K   ADS     GM++ H  G+H+GQ+ GPPTP\n"+
"Sbjct  121  QIYK---ADS--GLGGMADSHHHGDHTGQTHGPPTP  151\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_004310634.1<a name=XP_004310634></a> PREDICTED: transcription factor SOX-8 [Tursiops truncatus]  \n"+
"Length=376\n"+
"\n"+
" Score = 245 bits (626),  Expect = 8e-74, Method: Compositional matrix adjust.\n"+
" Identities = 118/181 (65%), Positives = 140/181 (77%), Gaps = 10/181 (6%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAARRKL  123\n"+
"            +++FP CIR+AVSQVLKGYDW+LVPMPVR  G    K KPHVKRPMNAFMVWAQAARRKL\n"+
"Sbjct  61   DERFPACIRDAVSQVLKGYDWSLVPMPVRGGGGGALKAKPHVKRPMNAFMVWAQAARRKL  120\n"+
"\n"+
"Query  124  ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK\n"+
"Sbjct  121  ADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  180\n"+
"\n"+
"Query  184  NGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKT  243\n"+
"             GQ++++   E  H     ++K        + +G+ + H  G+H+G +       ++P +\n"+
"Sbjct  181  TGQSDSDSGAELGHHPGGTVYK--------TDAGLGDAHHHGDHTGFTHATGLVVSSPVS  232\n"+
"\n"+
"Query  244  D  244\n"+
"            D\n"+
"Sbjct  233  D  233\n"+
"\n"+
"\n"+
" Score = 65.5 bits (158),  Expect = 1e-08, Method: Compositional matrix adjust.\n"+
" Identities = 52/123 (42%), Positives = 67/123 (54%), Gaps = 12/123 (10%)\n"+
"\n"+
"Query  394  RTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNL------PHYSPSYPPITRSQYDYTDHQN  447\n"+
"            R HIKTEQLSP HYS+Q   SP    Y  ++          + +    T SQ DYTD Q \n"+
"Sbjct  259  RPHIKTEQLSPGHYSDQSHGSPGHTDYGSYSAQASVTTAASAAAASSFTSSQCDYTDLQ-  317\n"+
"\n"+
"Query  448  SSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHS-PQHWEQPVYTQL  506\n"+
"            + +YY    G  +GLY  + Y +  +RP  +P+    G  S+P  HS P +WEQPVYT L\n"+
"Sbjct  318  APNYYGPYPGYPSGLYQ-YPYFHSPRRPYASPLL---GGLSVPPAHSPPSNWEQPVYTTL  373\n"+
"\n"+
"Query  507  TRP  509\n"+
"            TRP\n"+
"Sbjct  374  TRP  376\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAW34332.1<a name=AAW34332></a> SoxE1 [Petromyzon marinus]  \n"+
"Length=617\n"+
"\n"+
" Score = 252 bits (644),  Expect = 8e-74, Method: Compositional matrix adjust.\n"+
" Identities = 134/192 (70%), Positives = 151/192 (79%), Gaps = 7/192 (4%)\n"+
"\n"+
"Query  65   EEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLA  124\n"+
"            +++KFP  IREAVSQVLKGYDWTLVPMPVRVNGSSK KPHVKRPMNAFMVWAQAARRKLA\n"+
"Sbjct  84   DDEKFPDSIREAVSQVLKGYDWTLVPMPVRVNGSSKCKPHVKRPMNAFMVWAQAARRKLA  143\n"+
"\n"+
"Query  125  DQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            DQYPHLHNAELSKTLGKLWRLLNE+EKRPF+EEAERLRVQHKKDHPDYKYQPRRRKSVK \n"+
"Sbjct  144  DQYPHLHNAELSKTLGKLWRLLNENEKRPFIEEAERLRVQHKKDHPDYKYQPRRRKSVK-  202\n"+
"\n"+
"Query  185  GQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTD  244\n"+
"            G  + + A+         IFK +  +       + +  S   H+GQ+Q PPTPP+TPKT+\n"+
"Sbjct  203  GSGDGDAASPCGADPHGGIFKGVHGE----GGSLGDPISLSAHTGQAQSPPTPPSTPKTE  258\n"+
"\n"+
"Query  245  --VQPGKADLKR  254\n"+
"               + G  D KR\n"+
"Sbjct  259  QGAKAGGGDAKR  270\n"+
"\n"+
"\n"+
" Score = 62.4 bits (150),  Expect = 2e-07, Method: Compositional matrix adjust.\n"+
" Identities = 26/32 (81%), Positives = 30/32 (94%), Gaps = 0/32 (0%)\n"+
"\n"+
"Query  268  IDFRDVDIGELSSDVISNIETFDVNEFDQYLP  299\n"+
"            IDF +VD+GELSS+VISN+E FDVNEFDQYLP\n"+
"Sbjct  332  IDFSNVDMGELSSEVISNMEPFDVNEFDQYLP  363\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AGL08099.1<a name=AGL08099></a> SoxE [Sepia officinalis]  \n"+
"Length=357\n"+
"\n"+
" Score = 243 bits (619),  Expect = 4e-73, Method: Compositional matrix adjust.\n"+
" Identities = 130/237 (55%), Positives = 158/237 (67%), Gaps = 6/237 (3%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLAD  125\n"+
"            + +FP  I++AVSQVLKGYDWTLV MP R NG  K KPH+KRPMNAFMVWAQAARRKLAD\n"+
"Sbjct  35   DHRFPQQIQDAVSQVLKGYDWTLVSMPTRPNGGEKRKPHIKRPMNAFMVWAQAARRKLAD  94\n"+
"\n"+
"Query  126  QYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNG  185\n"+
"            QYPHLHNAELSKTLGKLWRLLNE EKRPF++EAERLR+QHKKD+PDYKYQPRRRK +K  \n"+
"Sbjct  95   QYPHLHNAELSKTLGKLWRLLNEKEKRPFIDEAERLRLQHKKDYPDYKYQPRRRKPLKGA  154\n"+
"\n"+
"Query  186  QAEAEEATE-QTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTD  244\n"+
"             +      + Q H+ P  I K LQ  SP   S     +    ++G    P  P T  + +\n"+
"Sbjct  155  VSNGSSGVDGQHHMPPGPILKTLQNSSPSPMSDGDSSNCSSPNNGSHGPPTPPTTPNQQE  214\n"+
"\n"+
"Query  245  VQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPN  301\n"+
"            +     D  R  + + +  +  PIDF  VD+    +DV+S +E  D +E DQYL  N\n"+
"Sbjct  215  LIKCMTDRSRMRQTMGQHSQAHPIDFSRVDL----ADVMS-LENIDEHELDQYLAMN  266\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EDL22429.1<a name=EDL22429></a> SRY-box containing gene 8, isoform CRA_a [Mus musculus]  \n"+
"Length=320\n"+
"\n"+
" Score = 241 bits (615),  Expect = 7e-73, Method: Compositional matrix adjust.\n"+
" Identities = 113/146 (77%), Positives = 127/146 (87%), Gaps = 2/146 (1%)\n"+
"\n"+
"Query  63   ESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSS--KNKPHVKRPMNAFMVWAQAAR  120\n"+
"            E+ +++FP CIR+AVSQVLKGYDW+LVPMPVR  G    K KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  55   EAADERFPACIRDAVSQVLKGYDWSLVPMPVRGGGGGTLKAKPHVKRPMNAFMVWAQAAR  114\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK\n"+
"Sbjct  115  RKLADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  174\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKA  206\n"+
"            SVK G+++++  TE  H     ++KA\n"+
"Sbjct  175  SVKTGRSDSDSGTELGHHPGGPMYKA  200\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013091187.1<a name=XP_013091187></a> PREDICTED: transcription factor Sox-10-like [Biomphalaria glabrata] \n"+
" \n"+
"Length=493\n"+
"\n"+
" Score = 246 bits (629),  Expect = 7e-73, Method: Compositional matrix adjust.\n"+
" Identities = 152/288 (53%), Positives = 172/288 (60%), Gaps = 23/288 (8%)\n"+
"\n"+
"Query  55   KGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMV  114\n"+
"            KG P      ++ +F   I+EAVS VL GYDW+LV  P R     K KPH+KRPMNAFMV\n"+
"Sbjct  53   KGHPTAGIGVDDPRFSQQIQEAVSHVLDGYDWSLVTTPARSQNGEKRKPHIKRPMNAFMV  112\n"+
"\n"+
"Query  115  WAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKY  174\n"+
"            WAQAARRKLADQYPHLHNAELSKTLGKLWRLLNE EK+PFVEEAERLRVQHKKDHPDYKY\n"+
"Sbjct  113  WAQAARRKLADQYPHLHNAELSKTLGKLWRLLNEGEKKPFVEEAERLRVQHKKDHPDYKY  172\n"+
"\n"+
"Query  175  QPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGP  234\n"+
"            QPRRRK+ K G A +  A    H S     K+ QA    SS+            G S GP\n"+
"Sbjct  173  QPRRRKAPKGGSATSGGA----HTS-----KSSQAGRDTSSASDDCDSECSSQQGNSNGP  223\n"+
"\n"+
"Query  235  PTPPTTPKTD--VQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVN  292\n"+
"            PTPP TP     V       +R  R    G    PIDF  +D   LS +V   IE FD  \n"+
"Sbjct  224  PTPPVTPNQQDPVVLKCMYERRAHRGYIMGPSGHPIDFSRMD---LSPEV---IEQFDDQ  277\n"+
"\n"+
"Query  293  EFDQYLPPNGHPGV--PATHGQVTYTGSYGISSTAATPASAGHVWMSK  338\n"+
"            + DQYLPP   PGV  P  H   +Y   Y +S    T A++G  W S+\n"+
"Sbjct  278  DLDQYLPP---PGVPHPQHHPDSSYPPCY-MSGPMQTSANSGSGWSSQ  321\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_016120675.1<a name=XP_016120675></a> PREDICTED: transcription factor SOX-10-like, partial [Sinocyclocheilus \n"+
"grahami]  \n"+
"Length=339\n"+
"\n"+
" Score = 241 bits (614),  Expect = 1e-72, Method: Compositional matrix adjust.\n"+
" Identities = 172/402 (43%), Positives = 226/402 (56%), Gaps = 97/402 (24%)\n"+
"\n"+
"Query  139  LGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK-------NGQAEAEE  191\n"+
"            L   +RLLNES+KRPF+EEAERLR QHKKD+P+YKYQPRRRK+ K       +G +E E \n"+
"Sbjct  4    LHVCFRLLNESDKRPFIEEAERLRKQHKKDYPEYKYQPRRRKNGKPGTNSEGDGHSEGEV  63\n"+
"\n"+
"Query  192  ATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGK-A  250\n"+
"            +  Q+H      +K+L  D  H+ S + + H P   +GQS  PPTPPTTPKT++Q GK +\n"+
"Sbjct  64   SHSQSH------YKSLHLDVVHAGSPLGDGHHP-HTTGQSHSPPTPPTTPKTELQGGKSS  116\n"+
"\n"+
"Query  251  DLKREGRPLPEG--------------GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQ  296\n"+
"            + KREG     G                +P IDF +VDIGE+S DV++N+E FDVNEFDQ\n"+
"Sbjct  117  EGKREGGASRSGLGVGADGSSASSSASGKPHIDFGNVDIGEISHDVMANMEPFDVNEFDQ  176\n"+
"\n"+
"Query  297  YLPPNGHPGVPATHGQVT----YTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQA  352\n"+
"            YLPPNGHP   +     +    YT  YGISS  A  +     W+SKQQ P          \n"+
"Sbjct  177  YLPPNGHPQSSSGTSAGSSASPYT--YGISSALAAASGHSTAWLSKQQLP----------  224\n"+
"\n"+
"Query  353  PPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQ---RTHIKTEQLSPSHYSE  409\n"+
"                                     Q H    L S+ G++Q    TH  ++  S SH   \n"+
"Sbjct  225  ------------------------SQQH----LGSDGGKTQIKSETHFSSDAASGSH---  253\n"+
"\n"+
"Query  410  QQQHSPQQIAYSPFNLPHYSPSYPPI-TRSQY-DYTDHQNSSSYYSHAAGQGTGLYSTFT  467\n"+
"                    + Y    LPHYS ++P + +R+Q+ +Y +HQ S SYY+H++ Q +GLYS F+\n"+
"Sbjct  254  --------VTY----LPHYSTAFPSLASRAQFAEYAEHQASGSYYAHSS-QTSGLYSAFS  300\n"+
"\n"+
"Query  468  YMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            YM P+QRP+YT I D     S+PQ+HSP HWEQPVYT L+RP\n"+
"Sbjct  301  YMGPSQRPLYTTIPDPG---SVPQSHSPTHWEQPVYTTLSRP  339\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">CAF87551.1<a name=CAF87551></a> unnamed protein product, partial [Tetraodon nigroviridis]  \n"+
"Length=296\n"+
"\n"+
" Score = 239 bits (611),  Expect = 1e-72, Method: Compositional matrix adjust.\n"+
" Identities = 134/166 (81%), Positives = 144/166 (87%), Gaps = 5/166 (3%)\n"+
"\n"+
"Query  143  WRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNA  202\n"+
"            +RLLNE EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQ ++E+  EQTHISPNA\n"+
"Sbjct  1    FRLLNEVEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQNDSEDG-EQTHISPNA  59\n"+
"\n"+
"Query  203  IFKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPE  261\n"+
"            IFKAL QADSP SS G  EVHSPGEHSGQSQGPPTPPTTPKTD+  GKADLKREGRP  E\n"+
"Sbjct  60   IFKALQQADSPASSLG--EVHSPGEHSGQSQGPPTPPTTPKTDLVSGKADLKREGRPTQE  117\n"+
"\n"+
"Query  262  G-GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV  306\n"+
"            G  RQ  IDF  VDIGELSS+VISN+ +FDV+EFDQYLPP+ H GV\n"+
"Sbjct  118  GTSRQLNIDFGAVDIGELSSEVISNMGSFDVDEFDQYLPPHSHAGV  163\n"+
"\n"+
"\n"+
" Score = 136 bits (343),  Expect = 1e-33, Method: Compositional matrix adjust.\n"+
" Identities = 64/92 (70%), Positives = 77/92 (84%), Gaps = 2/92 (2%)\n"+
"\n"+
"Query  420  YSPFNLPHYSPSYPPITRSQYDYTDHQN-SSSYYSHAAGQGTGLYSTFTYMNPAQRPMYT  478\n"+
"            Y  FNL +YS +  P  R+QYDY+DHQ  ++SYYS   GQG+GLYSTF+YMNP+QRPMYT\n"+
"Sbjct  205  YGSFNLQNYSAASYPSMRAQYDYSDHQGGANSYYSPTTGQGSGLYSTFSYMNPSQRPMYT  264\n"+
"\n"+
"Query  479  PIADTSGVPSIPQTHSPQHWE-QPVYTQLTRP  509\n"+
"            PIAD +GVPS+PQTHSPQHWE QP+YTQL+RP\n"+
"Sbjct  265  PIADNAGVPSVPQTHSPQHWEQQPIYTQLSRP  296\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KPP65044.1<a name=KPP65044></a> hypothetical protein Z043_116558 [Scleropages formosus]  \n"+
"Length=226\n"+
"\n"+
" Score = 236 bits (603),  Expect = 2e-72, Method: Compositional matrix adjust.\n"+
" Identities = 111/135 (82%), Positives = 121/135 (90%), Gaps = 1/135 (1%)\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            K + E+D+FPV IREAVSQVLKGYDWTLVPMPVR N  SK KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  64   KSDDEDDRFPVGIREAVSQVLKGYDWTLVPMPVRANSGSKGKPHVKRPMNAFMVWAQAAR  123\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKLADQYPHLHNAELSKTLGKLWRLLNES+KRPF+EEAERLR QHKKD+PDYKYQPRRRK\n"+
"Sbjct  124  RKLADQYPHLHNAELSKTLGKLWRLLNESDKRPFIEEAERLRKQHKKDYPDYKYQPRRRK  183\n"+
"\n"+
"Query  181  SVK-NGQAEAEEATE  194\n"+
"            + K N  +EA+  +E\n"+
"Sbjct  184  NGKPNSSSEADAHSE  198\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011601849.1<a name=XP_011601849></a> PREDICTED: transcription factor SOX-10 isoform X3 [Takifugu rubripes] \n"+
" \n"+
"Length=402\n"+
"\n"+
" Score = 237 bits (605),  Expect = 2e-70, Method: Compositional matrix adjust.\n"+
" Identities = 125/227 (55%), Positives = 150/227 (66%), Gaps = 25/227 (11%)\n"+
"\n"+
"Query  7    FMKMTDEQEKGLSGAPSPTMSEDSA----GSPCPSGSGSDTENTRPQE------NTFPKG  56\n"+
"            + KM+ E++       SP MS+DS     G    +  G D+     Q+      +     \n"+
"Sbjct  2    YSKMSREEQSFSEADLSPGMSDDSRSLSPGHSSGATGGGDSPLLGSQQPHLAGMDNTTAS  61\n"+
"\n"+
"Query  57   EPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWA  116\n"+
"                K + E+++FPV IR+AVSQVL  YDWT+VPMPVRVN  SKNKPHVKRPMNAFMVWA\n"+
"Sbjct  62   CSSAKSDDEDERFPVEIRDAVSQVLNCYDWTIVPMPVRVNSGSKNKPHVKRPMNAFMVWA  121\n"+
"\n"+
"Query  117  QAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQP  176\n"+
"            QAARRKLADQ+PHLHNAELSKTLGKLWRLLNES+KRPF+EEAERLR QHKKD+PDYKYQP\n"+
"Sbjct  122  QAARRKLADQHPHLHNAELSKTLGKLWRLLNESDKRPFIEEAERLRKQHKKDYPDYKYQP  181\n"+
"\n"+
"Query  177  RRRKSVK---------NGQAEAEEATEQTHISPNAIFKALQADSPHS  214\n"+
"            RRRK+ K         +G +E E +  Q+H      +K    D  HS\n"+
"Sbjct  182  RRRKNGKPGSGSGSEADGHSEGEISHSQSH------YKGFHLDVVHS  222\n"+
"\n"+
"\n"+
" Score = 115 bits (288),  Expect = 4e-25, Method: Compositional matrix adjust.\n"+
" Identities = 63/137 (46%), Positives = 88/137 (64%), Gaps = 9/137 (7%)\n"+
"\n"+
"Query  375  QQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPP  434\n"+
"            QQ   H  T L S+  ++Q   IK+E      +  +   +   + Y+P +LPHYS ++P \n"+
"Sbjct  273  QQQHQHHGTPLGSDASKAQ---IKSEAGGTGGHFAESASAGAHVTYTPLSLPHYSSAFPS  329\n"+
"\n"+
"Query  435  I-TRSQY-DYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQT  492\n"+
"              +R+Q+ DY DHQ S SYY+H++ Q +GLYS F+YM P+QRP+YT I D + V   PQ+\n"+
"Sbjct  330  FASRAQFADYADHQASGSYYAHSS-QASGLYSAFSYMGPSQRPLYTAITDPANV---PQS  385\n"+
"\n"+
"Query  493  HSPQHWEQPVYTQLTRP  509\n"+
"            HSP HWEQPVYT L+RP\n"+
"Sbjct  386  HSPTHWEQPVYTTLSRP  402\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013777180.1<a name=XP_013777180></a> PREDICTED: transcription factor Sox-8-like [Limulus polyphemus] \n"+
" \n"+
"Length=527\n"+
"\n"+
" Score = 241 bits (615),  Expect = 2e-70, Method: Compositional matrix adjust.\n"+
" Identities = 132/267 (49%), Positives = 166/267 (62%), Gaps = 12/267 (4%)\n"+
"\n"+
"Query  42   DTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKN  101\n"+
"            D++N R + +    G+ +    SE  +FP  IR+AVS+V +GY WTLVP P R + S K \n"+
"Sbjct  36   DSDNERSELDAEETGDSEQDSGSESGRFPQTIRDAVSRVFQGYHWTLVPTPTRPSSSDKR  95\n"+
"\n"+
"Query  102  KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERL  161\n"+
"            KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWR+L + EKRPFVEEAERL\n"+
"Sbjct  96   KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRVLRDEEKRPFVEEAERL  155\n"+
"\n"+
"Query  162  RVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHI-SPNAIFKALQADSPHSSSGMSE  220\n"+
"            R+ HKK+HPDYKYQPRRRK +K              +     +F++L+++    + G S \n"+
"Sbjct  156  RIIHKKEHPDYKYQPRRRKPMKGIHVNNPTVENVVGMQGATVMFRSLKSEKESPTGGQSP  215\n"+
"\n"+
"Query  221  V-----HSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRP-LPEGGRQP--PIDFRD  272\n"+
"            V      +P   S Q    P      +     G+  +    R  LP+ G Q   PIDF  \n"+
"Sbjct  216  VAPSPQQTPSPSSTQGPPTPPTTPNQRESAVGGRRVIDSRRRVHLPKQGEQEGQPIDFSH  275\n"+
"\n"+
"Query  273  VDIGELSSDVISNIETFDVNEFDQYLP  299\n"+
"            VD+G+LS++ I N   FD +E DQYLP\n"+
"Sbjct  276  VDVGQLSTEAIGN---FDESELDQYLP  299\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACU12333.1<a name=ACU12333></a> Sox9 isoform 17, partial [Crocodylus palustris]  \n"+
"Length=165\n"+
"\n"+
" Score = 229 bits (583),  Expect = 3e-70, Method: Compositional matrix adjust.\n"+
" Identities = 113/117 (97%), Positives = 113/117 (97%), Gaps = 1/117 (1%)\n"+
"\n"+
"Query  197  HISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREG  256\n"+
"            HISPNAIFKALQADSP SSS MSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGK DLKREG\n"+
"Sbjct  1    HISPNAIFKALQADSPQSSSSMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKQDLKREG  60\n"+
"\n"+
"Query  257  RPLPEGGRQPP-IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQ  312\n"+
"            RPLPEGGRQPP IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQ\n"+
"Sbjct  61   RPLPEGGRQPPHIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQ  117\n"+
"\n"+
"\n"+
" Score = 79.3 bits (194),  Expect = 2e-14, Method: Compositional matrix adjust.\n"+
" Identities = 40/46 (87%), Positives = 40/46 (87%), Gaps = 0/46 (0%)\n"+
"\n"+
"Query  393  QRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRS  438\n"+
"            QR HIKTEQLSPSHYSEQQQHSPQQI YS FNL HYS SYP ITRS\n"+
"Sbjct  120  QRPHIKTEQLSPSHYSEQQQHSPQQINYSSFNLQHYSSSYPTITRS  165\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ABC58684.1<a name=ABC58684></a> HMG box protein SoxE2 [Petromyzon marinus]  \n"+
"Length=579\n"+
"\n"+
" Score = 239 bits (611),  Expect = 2e-69, Method: Compositional matrix adjust.\n"+
" Identities = 146/262 (56%), Positives = 174/262 (66%), Gaps = 19/262 (7%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVN---GSSK--NKPHVKRPMNAFMVWAQAAR  120\n"+
"            +D F   I+ AVSQVL GYDW+L+P+PVR     G  K   KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  68   DDPFSESIQAAVSQVLDGYDWSLLPVPVRGAVGPGGCKPGEKPHVKRPMNAFMVWAQAAR  127\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RKL+DQYP LHNAELSKTLGKLWRLLNE EKRPFVEEAERLR+QHKKDHPDYKYQPRRRK\n"+
"Sbjct  128  RKLSDQYPQLHNAELSKTLGKLWRLLNEGEKRPFVEEAERLRMQHKKDHPDYKYQPRRRK  187\n"+
"\n"+
"Query  181  SVKNGQAEAEEATEQTHISPNAIFKALQADSPHSS----SGMSEVHSP--GEHSGQSQGP  234\n"+
"              + G+ +  +        P    +AL     H S    + + +VH P  G  +GQ Q P\n"+
"Sbjct  188  --QQGKGDGADTNSAEPGPPQLQARALGGAYVHLSGPGDAALLDVHGPHHGHVAGQPQSP  245\n"+
"\n"+
"Query  235  PTPPTTPKTDVQ--PGKADLKREGRPLPEGG----RQPPIDFRDVDIGELSSDVISNIET  288\n"+
"            PTPP TPKT     PGK   KR             R P +DF+ + +G+++++ IS +  \n"+
"Sbjct  246  PTPPNTPKTADHGPPGKGQGKRGHAGGAAATGEGPRHPSLDFQTIGMGDIAAEAISGMGN  305\n"+
"\n"+
"Query  289  FDVNEFDQYLPPNGHPGVPATH  310\n"+
"            FDVNEFDQYLPP+GH  V AT+\n"+
"Sbjct  306  FDVNEFDQYLPPSGHSSVIATN  327\n"+
"\n"+
"\n"+
" Score = 41.6 bits (96),  Expect = 0.72, Method: Compositional matrix adjust.\n"+
" Identities = 28/56 (50%), Positives = 37/56 (66%), Gaps = 6/56 (11%)\n"+
"\n"+
"Query  459  GTGLY-STFTYM--NPAQRPMYTPIADTSGVPSIPQTHS-PQHWEQ-PVYTQLTRP  509\n"+
"            G GLY + F +     AQRP+Y P+ + +  PS  Q+HS PQHW+  PVYTQL+RP\n"+
"Sbjct  525  GQGLYPAAFPHYLHGTAQRPLYPPVPEATS-PSPAQSHSPPQHWDSTPVYTQLSRP  579\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ABA02365.1<a name=ABA02365></a> sox family protein E1 [Nematostella vectensis]  \n"+
"Length=398\n"+
"\n"+
" Score = 233 bits (595),  Expect = 5e-69, Method: Compositional matrix adjust.\n"+
" Identities = 140/324 (43%), Positives = 185/324 (57%), Gaps = 31/324 (10%)\n"+
"\n"+
"Query  72   CIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLH  131\n"+
"             I  AV+ VL GYDW+L+P+PVRVNG    KPHVKRPMNAFMVWAQA RRKLADQYPHLH\n"+
"Sbjct  31   AIASAVNHVLDGYDWSLIPLPVRVNGIKTQKPHVKRPMNAFMVWAQAVRRKLADQYPHLH  90\n"+
"\n"+
"Query  132  NAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEE  191\n"+
"            NAELSKTLGKLW+LLN+SEK+PF+EEAERLR++HK++HPDYKYQPR++K   NG  +A +\n"+
"Sbjct  91   NAELSKTLGKLWKLLNDSEKKPFIEEAERLRIKHKREHPDYKYQPRKKKQKGNGNGDAGD  150\n"+
"\n"+
"Query  192  ATEQTHISPNAIFKALQADS---PHSSSGMSEVHSPGEHSG---------QSQGPPTPPT  239\n"+
"            AT    IS + + K L+ DS   P++    +   SP   S              P TP  \n"+
"Sbjct  151  AT----ISADDLLKVLKGDSKLVPNNGDASASCASPESVSDGEVSSSESCSVPSPETPTA  206\n"+
"\n"+
"Query  240  TP--KTDVQPGKADLKREGRP---LPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEF  294\n"+
"             P    DV+  +A   + G P     +      IDF   D+G+L++D+++ +   D  EF\n"+
"Sbjct  207  VPVKNEDVKNDEALSAQPGFPSCSKKDDSNSHAIDF---DVGDLTTDLMA-MGDVDSTEF  262\n"+
"\n"+
"Query  295  DQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPP  354\n"+
"            DQYLP      + +T  +   T      S + +  +         Q+PPP P    +   \n"+
"Sbjct  263  DQYLPTYSQALLDSTLTKAINTTQINTQSLSNSRFTTSQA----VQSPPPLPSSYREFMV  318\n"+
"\n"+
"Query  355  APQAPPQPQAAPPQQ--PAAPPQQ  376\n"+
"              Q  P   + PP +  P+A  QQ\n"+
"Sbjct  319  QLQKLPSEGSFPPNRVAPSATMQQ  342\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">CDQ74372.1<a name=CDQ74372></a> unnamed protein product [Oncorhynchus mykiss]  \n"+
"Length=528\n"+
"\n"+
" Score = 237 bits (604),  Expect = 7e-69, Method: Compositional matrix adjust.\n"+
" Identities = 116/179 (65%), Positives = 136/179 (76%), Gaps = 13/179 (7%)\n"+
"\n"+
"Query  56   GEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVW  115\n"+
"            G   +K + ++D+FP+ IREAVSQVL GYDWTLVPMPVRVN SSK+KPHVKRPMNAFMVW\n"+
"Sbjct  60   GGISIKSDEDDDRFPIGIREAVSQVLNGYDWTLVPMPVRVNSSSKSKPHVKRPMNAFMVW  119\n"+
"\n"+
"Query  116  AQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQ  175\n"+
"            AQAARRKLADQYPHLHNAELSKTLGKLWRLLNES+K+PF+EEAERLR QHKKD+P+YKYQ\n"+
"Sbjct  120  AQAARRKLADQYPHLHNAELSKTLGKLWRLLNESDKKPFIEEAERLRKQHKKDYPEYKYQ  179\n"+
"\n"+
"Query  176  PRRRKSVK-------NGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEH  227\n"+
"            PRRRK+ K       +G +E E +  Q+H      +K+L  D      G     + G H\n"+
"Sbjct  180  PRRRKNGKPGSGSEADGHSEGEVSHSQSH------YKSLHLDVAAHVGGAGSPLADGHH  232\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005886936.1<a name=XP_005886936></a> PREDICTED: transcription factor SOX-8 [Bos mutus]  \n"+
"Length=1004\n"+
"\n"+
" Score = 245 bits (625),  Expect = 1e-68, Method: Compositional matrix adjust.\n"+
" Identities = 178/385 (46%), Positives = 222/385 (58%), Gaps = 66/385 (17%)\n"+
"\n"+
"Query  136   SKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQ  195\n"+
"             ++TLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK GQ++++   E \n"+
"Sbjct  675   ARTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKTGQSDSDSGAEL  734\n"+
"\n"+
"Query  196   THISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDV-QPGKADLKR  254\n"+
"              H  P +++K        + +G+ + H   +H+GQ+ GPPTPPTTPKTD+   GK +LK \n"+
"Sbjct  735   GH-HPGSVYK--------TDAGLGDAHHHSDHTGQTHGPPTPPTTPKTDLHHGGKQELKL  785\n"+
"\n"+
"Query  255   EGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVT  314\n"+
"             EGR L + GRQ  IDF +VDI ELSS+VI N++TFDV+EFDQYLP NGH  +PA  GQ  \n"+
"Sbjct  786   EGRRLVDSGRQ-NIDFSNVDISELSSEVIGNMDTFDVHEFDQYLPLNGHSALPAEPGQPA  844\n"+
"\n"+
"Query  315   YTGSYGISS---TAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPA  371\n"+
"               GSYG +S   + A    A  VW  K                     P   A+P +  A\n"+
"Sbjct  845   AAGSYGGTSYSHSGAAGIGASPVWAHK-------------------GTPSASASPTE--A  883\n"+
"\n"+
"Query  372   APPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNL------  425\n"+
"              PP                   R HIKTEQLSP HY +Q   SP    Y  ++       \n"+
"Sbjct  884   GPP-------------------RPHIKTEQLSPGHYGDQSHGSPGHADYGSYSAQASVTT  924\n"+
"\n"+
"Query  426   PHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSG  485\n"+
"                + +    T SQ DYTD Q + SYY    G  +GLY  + Y +  +RP  +P+    G\n"+
"Sbjct  925   AAPAAAASSFTSSQCDYTDLQ-APSYYGPFPGYPSGLYQ-YPYFHSPRRPYASPLL---G  979\n"+
"\n"+
"Query  486   VPSIPQTHS-PQHWEQPVYTQLTRP  509\n"+
"               S+P  HS P +WEQPVYT LTRP\n"+
"Sbjct  980   GLSVPPAHSPPSNWEQPVYTTLTRP  1004\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KFM81451.1<a name=KFM81451></a> Transcription factor Sox-9, partial [Stegodyphus mimosarum]  \n"+
"\n"+
"Length=284\n"+
"\n"+
" Score = 228 bits (580),  Expect = 3e-68, Method: Compositional matrix adjust.\n"+
" Identities = 124/238 (52%), Positives = 162/238 (68%), Gaps = 19/238 (8%)\n"+
"\n"+
"Query  69   FPVCIREAVSQVLKGYDWTLVPMPVRVN-----GSSKNKPHVKRPMNAFMVWAQAARRKL  123\n"+
"            +P  IR AVS+VL+GYDW++VP PVR       G  + KP+VKRPMNAFMVWAQAARRKL\n"+
"Sbjct  21   YPASIRAAVSRVLRGYDWSVVPAPVRSGQGNGAGGDRRKPYVKRPMNAFMVWAQAARRKL  80\n"+
"\n"+
"Query  124  ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ADQYPHLHNAELSKTLGKLWRLLNE +KRPFVEEAERLR+ HK++HPDYKYQPRR+K+ K\n"+
"Sbjct  81   ADQYPHLHNAELSKTLGKLWRLLNEEDKRPFVEEAERLRLIHKREHPDYKYQPRRKKTSK  140\n"+
"\n"+
"Query  184  NGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKT  243\n"+
"            +G  + ++   Q + +   +F++L+    +S S  + V +  E    S  P  P + P  \n"+
"Sbjct  141  SGNEKPQQPAGQANTA--IVFRSLK----YSDSDSNSVKTEHEGGAPSSPPTPPSSPPLE  194\n"+
"\n"+
"Query  244  DVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPN  301\n"+
"            +V P    LK +G        + PIDF  VD+G+L+ + + N+   D +E DQYLPP+\n"+
"Sbjct  195  EVSPLNRRLKPDGSSY-----EQPIDFSYVDVGQLTREAMDNL---DESELDQYLPPS  244\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013789847.1<a name=XP_013789847></a> PREDICTED: transcription factor Sox-9-B-like [Limulus polyphemus] \n"+
" \n"+
"Length=519\n"+
"\n"+
" Score = 233 bits (595),  Expect = 1e-67, Method: Compositional matrix adjust.\n"+
" Identities = 136/280 (49%), Positives = 173/280 (62%), Gaps = 20/280 (7%)\n"+
"\n"+
"Query  41   SDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSK  100\n"+
"            S+ +N R   +    G+      +E  +FP  I +AVS+V +GY W LVP P R++ S K\n"+
"Sbjct  31   SEFDNKRSVLDFEETGDSSQDSNNETGRFPPSICDAVSRVFQGYHWRLVPTPSRLSSSDK  90\n"+
"\n"+
"Query  101  NKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAER  160\n"+
"             K HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG+LWR L + EKRPFVEEAER\n"+
"Sbjct  91   RKCHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGRLWRQLGDEEKRPFVEEAER  150\n"+
"\n"+
"Query  161  LRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMS-  219\n"+
"            LRV HKK HPDYKYQPRRRK +K+    + E           +F++++ +  +  SG   \n"+
"Sbjct  151  LRVIHKKKHPDYKYQPRRRKPMKSINIPSVEPIYTVQ-GATVLFRSVKLEKENPLSGRCH  209\n"+
"\n"+
"Query  220  EVHSPGE-HSGQSQGPPTPPTTPKTDVQPGKADLKREGR--------PLPEGGRQP--PI  268\n"+
"            E  SP E  S  S GP TPP TP      G++ ++ +GR         + + G+Q   PI\n"+
"Sbjct  210  EAPSPQETFSPSSTGPLTPPATP----NQGESTVRGKGRFGNLSTNINITKQGQQESQPI  265\n"+
"\n"+
"Query  269  DFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPA  308\n"+
"            DF  VD+G+LS++ I N   FD +E DQYL     P V +\n"+
"Sbjct  266  DFSHVDVGQLSTEAIDN---FDESELDQYLTGQNCPIVSS  302\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KPP60376.1<a name=KPP60376></a> transcription factor SOX-8-like [Scleropages formosus]  \n"+
"Length=376\n"+
"\n"+
" Score = 226 bits (576),  Expect = 2e-66, Method: Compositional matrix adjust.\n"+
" Identities = 152/286 (53%), Positives = 184/286 (64%), Gaps = 40/286 (14%)\n"+
"\n"+
"Query  7    FMKMTDEQEKGLSGAP------SPTMSEDSAGSPCPSG-SGSDTENTRPQENTFPKGEPD  59\n"+
"              KMT+E +K L+  P      S ++S++ + S  PS  +GSD   +        K   D\n"+
"Sbjct  1    MFKMTEELDKSLTDPPCSPAGTSSSVSQEDSDSDAPSSPAGSDGHGSLLIPGMGKKMNGD  60\n"+
"\n"+
"Query  60   LKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAA  119\n"+
"                 E+++FP CIREAVSQVLKGYDW+LVPMPVR NGS K+KPHVKRPMNA        \n"+
"Sbjct  61   -----EDERFPACIREAVSQVLKGYDWSLVPMPVRGNGSLKSKPHVKRPMNA--------  107\n"+
"\n"+
"Query  120  RRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"                          ELSKTLGKLWRLL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRR\n"+
"Sbjct  108  -------------XELSKTLGKLWRLLSENEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  154\n"+
"\n"+
"Query  180  KSVKNGQAEAEEATEQTHISPNAIFKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPPTPP  238\n"+
"            KSVK GQ++++   E  H     ++KA           GM++ H   EH+GQ+ GPPTPP\n"+
"Sbjct  155  KSVKPGQSDSDSGAELGH----QMYKAEPGMGGMGGMGGMADGHHHQEHAGQTHGPPTPP  210\n"+
"\n"+
"Query  239  TTPKTDV-QPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVI  283\n"+
"            TTPKTD+   GK +LK EGR L + GRQ  IDF +VDI ELS+DVI\n"+
"Sbjct  211  TTPKTDLHHGGKQELKHEGRRLLDAGRQ-NIDFSNVDISELSTDVI  255\n"+
"\n"+
"\n"+
" Score = 68.2 bits (165),  Expect = 2e-09, Method: Compositional matrix adjust.\n"+
" Identities = 53/135 (39%), Positives = 76/135 (56%), Gaps = 12/135 (9%)\n"+
"\n"+
"Query  382  LTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNL------PHYSPSYPPI  435\n"+
"            ++ LS++  + QR HIKTEQLSP HY E    SP    +  ++          + +    \n"+
"Sbjct  247  ISELSTDVIRQQRPHIKTEQLSPGHYGEHPHGSPTHSDFGTYSTQGCITSAASASAAASF  306\n"+
"\n"+
"Query  436  TRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP  495\n"+
"            + SQ DYTD Q SS+YYS  +G  +G+Y  + Y   ++R   +PI ++    SIP +HSP\n"+
"Sbjct  307  SSSQCDYTDLQ-SSNYYSPYSGYPSGIYQ-YPYFPSSRRAYGSPILNSL---SIPPSHSP  361\n"+
"\n"+
"Query  496  -QHWEQPVYTQLTRP  509\n"+
"               WEQPVYT L+RP\n"+
"Sbjct  362  TASWEQPVYTTLSRP  376\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009940020.1<a name=XP_009940020></a> PREDICTED: transcription factor SOX-9 [Opisthocomus hoazin]  \n"+
"\n"+
"Length=187\n"+
"\n"+
" Score = 219 bits (559),  Expect = 2e-66, Method: Compositional matrix adjust.\n"+
" Identities = 106/116 (91%), Positives = 108/116 (93%), Gaps = 0/116 (0%)\n"+
"\n"+
"Query  394  RTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYS  453\n"+
"            RTHIKTEQLSPSHYSEQQQHSPQQI YS FNL H+S SYP ITRSQYDYTDHQNSSSYYS\n"+
"Sbjct  72   RTHIKTEQLSPSHYSEQQQHSPQQINYSSFNLQHFSSSYPTITRSQYDYTDHQNSSSYYS  131\n"+
"\n"+
"Query  454  HAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            HAAGQ + LYSTFTYMNP QRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  132  HAAGQSSSLYSTFTYMNPTQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  187\n"+
"\n"+
"\n"+
" Score = 85.5 bits (210),  Expect = 2e-16, Method: Compositional matrix adjust.\n"+
" Identities = 47/55 (85%), Positives = 51/55 (93%), Gaps = 0/55 (0%)\n"+
"\n"+
"Query  176  PRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQ  230\n"+
"            PRRRKSVKNGQ+E EE +EQTHISPNAIFKALQADSP SSS +SEVHSPGEHSG+\n"+
"Sbjct  13   PRRRKSVKNGQSEQEEGSEQTHISPNAIFKALQADSPQSSSSISEVHSPGEHSGR  67\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KXJ11873.1<a name=KXJ11873></a> Transcription factor SOX-9 [Exaiptasia pallida]  \n"+
"Length=404\n"+
"\n"+
" Score = 219 bits (558),  Expect = 2e-63, Method: Compositional matrix adjust.\n"+
" Identities = 97/139 (70%), Positives = 116/139 (83%), Gaps = 4/139 (3%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV+ VL GYDW+L+P+PVRVNG  K K HVKRPMNAFMVWAQAARRKLADQYPHLHN\n"+
"Sbjct  28   IASAVNNVLDGYDWSLIPLPVRVNGGHKQKAHVKRPMNAFMVWAQAARRKLADQYPHLHN  87\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA  192\n"+
"            AELSKTLGKLW+LLN+SEK+PF+EEAERLR++HK++HPDYKYQPRR+K   NG  E+ ++\n"+
"Sbjct  88   AELSKTLGKLWKLLNDSEKKPFIEEAERLRIKHKREHPDYKYQPRRKKQKGNGVGESGDS  147\n"+
"\n"+
"Query  193  TEQTHISPNAIFKALQADS  211\n"+
"            T    IS + + K L+ DS\n"+
"Sbjct  148  T----ISADDLLKVLKGDS  162\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002122233.2<a name=XP_002122233></a> PREDICTED: uncharacterized protein LOC445804 [Ciona intestinalis] \n"+
" \n"+
"Length=823\n"+
"\n"+
" Score = 228 bits (580),  Expect = 3e-63, Method: Compositional matrix adjust.\n"+
" Identities = 102/126 (81%), Positives = 112/126 (89%), Gaps = 0/126 (0%)\n"+
"\n"+
"Query  65   EEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLA  124\n"+
"            E+D     I++AVSQVLKGYDWTLVPMPVR+NGS K KPHVKRPMNAFMVWAQAARRKLA\n"+
"Sbjct  182  EKDDMSKDIKDAVSQVLKGYDWTLVPMPVRMNGSQKTKPHVKRPMNAFMVWAQAARRKLA  241\n"+
"\n"+
"Query  125  DQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            DQYPHLHNAELSKTLGKLWRLL+E+EK+PFV+EAERLR++HKKDHPDYKYQPRRRKS K \n"+
"Sbjct  242  DQYPHLHNAELSKTLGKLWRLLSETEKKPFVDEAERLRIKHKKDHPDYKYQPRRRKSSKT  301\n"+
"\n"+
"Query  185  GQAEAE  190\n"+
"                 E\n"+
"Sbjct  302  ASGVGE  307\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ELU17008.1<a name=ELU17008></a> hypothetical protein CAPTEDRAFT_175609 [Capitella teleta]  \n"+
"Length=453\n"+
"\n"+
" Score = 218 bits (554),  Expect = 3e-62, Method: Compositional matrix adjust.\n"+
" Identities = 133/255 (52%), Positives = 155/255 (61%), Gaps = 19/255 (7%)\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRV-NGSSKNKPHVKRPMNAFMVWAQAA  119\n"+
"            K +   + FP  I++AVS VL GYDWTL+PMP R   G  K KPH+KRPMNAFMVWAQAA\n"+
"Sbjct  39   KTDRNGEAFPREIQDAVSHVLDGYDWTLIPMPSRTPTGGDKRKPHIKRPMNAFMVWAQAA  98\n"+
"\n"+
"Query  120  RRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            RRKLADQYPHLHNAELSKTLGKLWRLL+E EK+PF+EEAERLR QHK+ HPDYKYQPRRR\n"+
"Sbjct  99   RRKLADQYPHLHNAELSKTLGKLWRLLSEEEKKPFIEEAERLRQQHKQAHPDYKYQPRRR  158\n"+
"\n"+
"Query  180  KSVK---NGQAEAEEATEQT---HISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQG  233\n"+
"            K +K   NG   A   T      H+S N I+K+     P SS   S   SP         \n"+
"Sbjct  159  KPLKGPSNGTNPAAMETSHMTHGHMSQN-IYKSPMV--PGSSVECSLNRSPTLTGPNGPP  215\n"+
"\n"+
"Query  234  PPTPPTT-PKTDVQPGKADLKREGRPL---PEGGRQP---PIDFRDVDIGELSSDVISNI  286\n"+
"             P      P   +QP  + L  + RP    P  G  P   P+DF  +D+    S  I  +\n"+
"Sbjct  216  TPPTTPNHPSHRIQPCPSSL--QDRPHVSPPSPGNSPQNQPLDFSHMDVVSELSPGIMTM  273\n"+
"\n"+
"Query  287  ETFDVNEFDQYLPPN  301\n"+
"            E F+  E DQYLP N\n"+
"Sbjct  274  ENFEDGELDQYLPMN  288\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAO39401.1<a name=AAO39401></a> transcription factor sox-9, partial [Ornithorhynchus anatinus] \n"+
" \n"+
"Length=187\n"+
"\n"+
" Score = 206 bits (525),  Expect = 2e-61, Method: Compositional matrix adjust.\n"+
" Identities = 131/193 (68%), Positives = 139/193 (72%), Gaps = 12/193 (6%)\n"+
"\n"+
"Query  282  VISNIETFDVNEFDQYLPPNGHPGVPATHGQ----VTYTGSYGISSTAATPASAGHVWMS  337\n"+
"            VISNIETFDVNEFDQYLPPNGHPGVPA HGQ        G      ++A PAS+GHVW+S\n"+
"Sbjct  1    VISNIETFDVNEFDQYLPPNGHPGVPAAHGQPGQVTYTGGYGIGGGSSAPPASSGHVWLS  60\n"+
"\n"+
"Query  338  KQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAH-TLTTLSSEPGQSQ-RT  395\n"+
"            KQQ       Q  Q    P      Q    QQ   PP Q   H TLTTLS E GQ+Q RT\n"+
"Sbjct  61   KQQQ------QQQQQQQPPPQQSPQQQQQQQQQQQPPPQQAQHPTLTTLSGEQGQAQQRT  114\n"+
"\n"+
"Query  396  HIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHA  455\n"+
"            HIKTEQLSPSHYSEQQQHSPQQI YSPFNLPHYSP YP ITRSQYDYTDHQ+S+SYYSHA\n"+
"Sbjct  115  HIKTEQLSPSHYSEQQQHSPQQINYSPFNLPHYSPLYPTITRSQYDYTDHQSSNSYYSHA  174\n"+
"\n"+
"Query  456  AGQGTGLYSTFTY  468\n"+
"            AGQ +GLYSTFTY\n"+
"Sbjct  175  AGQSSGLYSTFTY  187\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">CAF96993.1<a name=CAF96993></a> unnamed protein product [Tetraodon nigroviridis]  \n"+
"Length=411\n"+
"\n"+
" Score = 214 bits (544),  Expect = 2e-61, Method: Compositional matrix adjust.\n"+
" Identities = 103/171 (60%), Positives = 126/171 (74%), Gaps = 3/171 (2%)\n"+
"\n"+
"Query  10   MTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKF  69\n"+
"            MT+E+  G + +P    S   +GS   + +  D  N+     T     P  +  +E+++ \n"+
"Sbjct  1    MTEERLTGSARSPGNETSMSQSGSGSEAPTEKDNSNSICLSGTI---TPKRRSSTEDERL  57\n"+
"\n"+
"Query  70   PVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPH  129\n"+
"            PVCIR+AVS VLKGYDW+LV +    +   KNKPHVKRPMNAFMVWAQAAR+KLADQYP \n"+
"Sbjct  58   PVCIRDAVSHVLKGYDWSLVAVSSHGDRGLKNKPHVKRPMNAFMVWAQAARKKLADQYPQ  117\n"+
"\n"+
"Query  130  LHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            LHNAELSKTLGKLWRLL E+EKRPF+EEA+RLR+QHKKD+PDYKYQPRRRK\n"+
"Sbjct  118  LHNAELSKTLGKLWRLLTETEKRPFIEEADRLRLQHKKDYPDYKYQPRRRK  168\n"+
"\n"+
"\n"+
" Score = 49.3 bits (116),  Expect = 0.002, Method: Compositional matrix adjust.\n"+
" Identities = 43/127 (34%), Positives = 61/127 (48%), Gaps = 10/127 (8%)\n"+
"\n"+
"Query  385  LSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQI--AYSPFNLPHYSPSYPPITRSQYDY  442\n"+
"            + SE    ++  +KTEQ+SP   S      P  +    +P + P+   + PP      D+\n"+
"Sbjct  293  IQSEDAAPRKPRVKTEQMSPDRRSGLSASPPSSLQPEGTPGSTPNAPSTRPP------DH  346\n"+
"\n"+
"Query  443  TDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPV  502\n"+
"             D Q SSS+YS  AG    LY    + +P+  P  TP+ ++      P    P  WEQPV\n"+
"Sbjct  347  ADLQ-SSSFYSAMAGYAAPLYQHPCF-HPSCLPYGTPLINSLASAPTPSHSPPSGWEQPV  404\n"+
"\n"+
"Query  503  YTQLTRP  509\n"+
"            YT LTRP\n"+
"Sbjct  405  YTTLTRP  411\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005102100.1<a name=XP_005102100></a> PREDICTED: transcription factor Sox-10-like [Aplysia californica] \n"+
" \n"+
"Length=589\n"+
"\n"+
" Score = 216 bits (551),  Expect = 2e-60, Method: Compositional matrix adjust.\n"+
" Identities = 145/306 (47%), Positives = 174/306 (57%), Gaps = 28/306 (9%)\n"+
"\n"+
"Query  64   SEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKL  123\n"+
"            +++ +F   I+EAVS VL+GYDW+LV  P R     K KPH+KRPMNAFMVWAQAARRKL\n"+
"Sbjct  94   ADDPRFSQQIQEAVSHVLEGYDWSLVTTPARNQNGEKRKPHIKRPMNAFMVWAQAARRKL  153\n"+
"\n"+
"Query  124  ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ADQYPHLHNAELSKTLGKLWRLLNE+EK+PFVEEAERLRVQHKKDHPDYKYQPRRRK  K\n"+
"Sbjct  154  ADQYPHLHNAELSKTLGKLWRLLNEAEKKPFVEEAERLRVQHKKDHPDYKYQPRRRKPPK  213\n"+
"\n"+
"Query  184  NGQAEAEEATEQTHISPNAIFKALQADS-----PHSSSGMSEVHSPGEHSGQSQGPPTPP  238\n"+
"                   +     H  P++   ++++         S S         +  G S GPPTPP\n"+
"Sbjct  214  GPGGHGSD-----HSGPSSGGHSMKSSGGGVRDSSSPSDDCSSECSSQQGGNSNGPPTPP  268\n"+
"\n"+
"Query  239  TTP-KTDVQPGKADLKREG-RPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQ  296\n"+
"             TP + D    K    R+G R    G    PIDF  +D   LS +VI   +     + DQ\n"+
"Sbjct  269  VTPNQHDAVSLKCMYDRKGQRGYIMGPSGHPIDFSRMD---LSPEVIDQFDD---QDLDQ  322\n"+
"\n"+
"Query  297  YLPPNGHPGVPATHG----------QVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPP  346\n"+
"            YLP  G P   A HG             Y G    S ++A+PA A    M+   +  PP \n"+
"Sbjct  323  YLPLPGMPHPLAHHGGHHSEVGPYNAPCYLGPPISSVSSASPAWASGYRMTTPASCLPPY  382\n"+
"\n"+
"Query  347  QQPPQA  352\n"+
"              PP  \n"+
"Sbjct  383  MAPPHG  388\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ERE68692.1<a name=ERE68692></a> transcription factor SOX-8 [Cricetulus griseus]  \n"+
"Length=361\n"+
"\n"+
" Score = 209 bits (533),  Expect = 3e-60, Method: Compositional matrix adjust.\n"+
" Identities = 164/373 (44%), Positives = 212/373 (57%), Gaps = 68/373 (18%)\n"+
"\n"+
"Query  151  KRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQAD  210\n"+
"            KRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK G+++++  TE  H     ++KA    \n"+
"Sbjct  43   KRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKAGRSDSDSGTELGHHPGGPMYKA----  98\n"+
"\n"+
"Query  211  SPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQ----PGKADLKREGRPLPEGGRQP  266\n"+
"                 + +S+ H   +H+GQ+ GPPTPPTTPKTD+      GK +L+ EGR L + GRQ \n"+
"Sbjct  99   ----DAVLSDAHHHSDHTGQTHGPPTPPTTPKTDLHQASSGGKQELRLEGRRLVDSGRQ-  153\n"+
"\n"+
"Query  267  PIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYG---ISS  323\n"+
"             IDF +VDI ELSS+VISN++TFDV+EFDQYLP NGH  +P    Q T +GSYG    S \n"+
"Sbjct  154  NIDFSNVDISELSSEVISNMDTFDVHEFDQYLPLNGHSALPTEPSQATASGSYGGTSYSH  213\n"+
"\n"+
"Query  324  TAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLT  383\n"+
"            + AT   A  VW  K                AP A   P  A P +P             \n"+
"Sbjct  214  SGATGIGASPVWAHKG---------------APSASASPTEAGPLRP-------------  245\n"+
"\n"+
"Query  384  TLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNL------PHYSPSYPPITR  437\n"+
"                        HIKTEQLSP+HY++Q   SP +  Y  ++          + +      \n"+
"Sbjct  246  ------------HIKTEQLSPTHYNDQSHGSPGRADYGSYSAQASVTTAASATAASSFAS  293\n"+
"\n"+
"Query  438  SQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP-Q  496\n"+
"            +Q DYTD Q +S+YYS   G   GLY  + Y + ++RP  +P+ +  G+ S+P  HSP  \n"+
"Sbjct  294  AQCDYTDLQ-ASNYYSPYPGYPPGLYQ-YPYFHSSRRPYASPLLN--GL-SMPPAHSPSS  348\n"+
"\n"+
"Query  497  HWEQPVYTQLTRP  509\n"+
"            +W+QPVYT LTRP\n"+
"Sbjct  349  NWDQPVYTTLTRP  361\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015762367.1<a name=XP_015762367></a> PREDICTED: transcription factor SOX-9-like [Acropora digitifera] \n"+
" \n"+
"Length=469\n"+
"\n"+
" Score = 211 bits (538),  Expect = 7e-60, Method: Compositional matrix adjust.\n"+
" Identities = 95/139 (68%), Positives = 115/139 (83%), Gaps = 4/139 (3%)\n"+
"\n"+
"Query  72   CIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLH  131\n"+
"             I  AV+ VL GYDW+L+P+PVRVNG  K+KPHVKRPMNAFMVWAQAARRKLADQYPHLH\n"+
"Sbjct  87   AIATAVNHVLDGYDWSLIPLPVRVNGGHKHKPHVKRPMNAFMVWAQAARRKLADQYPHLH  146\n"+
"\n"+
"Query  132  NAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEE  191\n"+
"            NAELSKTLGKLW++L ++EK+PF+EEAERLR++HK++HPDYKYQPRR+K   NG  +  E\n"+
"Sbjct  147  NAELSKTLGKLWKMLKDAEKKPFIEEAERLRLKHKREHPDYKYQPRRKKQKGNGGPDQPE  206\n"+
"\n"+
"Query  192  ATEQTHISPNAIFKALQAD  210\n"+
"            AT    IS + + K L+ D\n"+
"Sbjct  207  AT----ISADDLLKVLKGD  221\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010197492.1<a name=XP_010197492></a> PREDICTED: transcription factor SOX-8, partial [Colius striatus] \n"+
" \n"+
"Length=234\n"+
"\n"+
" Score = 204 bits (519),  Expect = 7e-60, Method: Compositional matrix adjust.\n"+
" Identities = 141/279 (51%), Positives = 168/279 (60%), Gaps = 49/279 (18%)\n"+
"\n"+
"Query  145  LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIF  204\n"+
"            LL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK GQ++++   E +H +   I+\n"+
"Sbjct  1    LLSENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKAGQSDSDSGAELSHHAGTQIY  60\n"+
"\n"+
"Query  205  KALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPG-KADLKREGRPLPEGG  263\n"+
"            K   ADS     GM + H   +H+GQ+ GPPTPPTTPKTD+  G K +LK EGR L E G\n"+
"Sbjct  61   K---ADS--GLGGMPDSHHHTDHTGQTHGPPTPPTTPKTDLHHGSKQELKHEGRRLVESG  115\n"+
"\n"+
"Query  264  RQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISS  323\n"+
"            RQ  IDF +VDI ELSS+VI+N+ETFDV+EFDQYLP NGH  +PA HG     GSYG S \n"+
"Sbjct  116  RQ-NIDFSNVDISELSSEVINNMETFDVHEFDQYLPLNGHAAMPADHGPSATAGSYGASY  174\n"+
"\n"+
"Query  324  TAATPASAG--HVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHT  381\n"+
"            + +   + G   VW  K  A   P                                    \n"+
"Sbjct  175  SHSATGTGGTNQVWTHKNPASASPS-----------------------------------  199\n"+
"\n"+
"Query  382  LTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAY  420\n"+
"                S++ GQ QR HIKTEQLSPSHYS+Q   SP    Y\n"+
"Sbjct  200  ----SADSGQ-QRPHIKTEQLSPSHYSDQSHGSPAHSDY  233\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_008692170.1<a name=XP_008692170></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-9 [Ursus \n"+
"maritimus]  \n"+
"Length=195\n"+
"\n"+
" Score = 201 bits (510),  Expect = 4e-59, Method: Compositional matrix adjust.\n"+
" Identities = 96/98 (98%), Positives = 97/98 (99%), Gaps = 0/98 (0%)\n"+
"\n"+
"Query  412  QHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNP  471\n"+
"            QHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNS SYYSHAAGQG+GLYSTFTYMNP\n"+
"Sbjct  98   QHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSGSYYSHAAGQGSGLYSTFTYMNP  157\n"+
"\n"+
"Query  472  AQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            AQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  158  AQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  195\n"+
"\n"+
"\n"+
" Score = 144 bits (363),  Expect = 1e-37, Method: Compositional matrix adjust.\n"+
" Identities = 77/77 (100%), Positives = 77/77 (100%), Gaps = 0/77 (0%)\n"+
"\n"+
"Query  229  GQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIET  288\n"+
"            GQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIET\n"+
"Sbjct  21   GQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIET  80\n"+
"\n"+
"Query  289  FDVNEFDQYLPPNGHPG  305\n"+
"            FDVNEFDQYLPPNGHPG\n"+
"Sbjct  81   FDVNEFDQYLPPNGHPG  97\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAH78333.1<a name=AAH78333></a> Sox10 protein [Danio rerio]  \n"+
"Length=169\n"+
"\n"+
" Score = 199 bits (507),  Expect = 6e-59, Method: Compositional matrix adjust.\n"+
" Identities = 101/152 (66%), Positives = 111/152 (73%), Gaps = 20/152 (13%)\n"+
"\n"+
"Query  19   SGAPSPTMSEDSAGSPCP------SGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVC  72\n"+
"            SGAP        A SP P      SG G D             G   +K + E+D+FP+ \n"+
"Sbjct  23   SGAPG------GADSPLPGQQSQMSGIGDDGAGV--------SGGVSVKSDEEDDRFPIG  68\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            IREAVSQVL GYDWTLVPMPVRVN  SK+KPHVKRPMNAFMVWAQAARRKLADQYPHLHN\n"+
"Sbjct  69   IREAVSQVLNGYDWTLVPMPVRVNSGSKSKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  128\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            AELSKTLGKLWRLLNE+++RPF+EEAERLR Q\n"+
"Sbjct  129  AELSKTLGKLWRLLNETDRRPFIEEAERLRKQ  160\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013787422.1<a name=XP_013787422></a> PREDICTED: transcription factor Sox-10-like [Limulus polyphemus] \n"+
" \n"+
"Length=478\n"+
"\n"+
" Score = 209 bits (531),  Expect = 1e-58, Method: Compositional matrix adjust.\n"+
" Identities = 129/294 (44%), Positives = 168/294 (57%), Gaps = 21/294 (7%)\n"+
"\n"+
"Query  37   SGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVN  96\n"+
"            SGSG D        +  P+     +   E   FP  I +AVS+VLKGYDWTLV  P + N\n"+
"Sbjct  21   SGSGQDQRQGHQLSDLMPEDNKSQENIDENLGFPSSIHDAVSRVLKGYDWTLVSNPPKHN  80\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"             SSK +P+VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG+LWRLL + +KRPFVE\n"+
"Sbjct  81   NSSKRRPYVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGRLWRLLGDEDKRPFVE  140\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRKSVKN-GQAEAEEATEQTHISPNAIFKALQADSPHSS  215\n"+
"            EAERLR  HKK++PDYKYQPRRRK+ K  G    +E   +       +F +L+ ++    \n"+
"Sbjct  141  EAERLRQVHKKNYPDYKYQPRRRKTGKYPGSLGTDEPVSEMQ-GATVVFSSLKTENV---  196\n"+
"\n"+
"Query  216  SGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPG--KADLKR-EGRPLPEGGRQP--PIDF  270\n"+
"             G     +  + S +       P+T    +  G    +++R E   L    +Q   P  F\n"+
"Sbjct  197  -GTLRTSAINQQSSK-------PSTNSNLIGIGWKSENMERFEHVGLQSHAQQTAQPNGF  248\n"+
"\n"+
"Query  271  RDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISST  324\n"+
"               D+ +L+S+ + N++ F +   DQ LPP G      T      T S+  SST\n"+
"Sbjct  249  NQGDMSKLTSEGMCNMDLFQI---DQCLPPFGALSSSWTSTSPDDTNSFNFSST  299\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ALM01447.1<a name=ALM01447></a> SoxE [Limulus polyphemus]  \n"+
"Length=445\n"+
"\n"+
" Score = 206 bits (525),  Expect = 3e-58, Method: Compositional matrix adjust.\n"+
" Identities = 122/245 (50%), Positives = 149/245 (61%), Gaps = 32/245 (13%)\n"+
"\n"+
"Query  62   KESEEDK--FPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAA  119\n"+
"            KES E+K  FP  I +AVS+VLKGYDWT VP P + N S K +P+VKRPMNAFMVWAQAA\n"+
"Sbjct  46   KESLENKAGFPPSIHDAVSRVLKGYDWTFVPTPTKHNNSDKRRPYVKRPMNAFMVWAQAA  105\n"+
"\n"+
"Query  120  RRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            RRKLA QYPHLHNAELSKTLG+LWRLL + EKRPFVEEA+RLR  HKK HP+YKYQPRRR\n"+
"Sbjct  106  RRKLAGQYPHLHNAELSKTLGRLWRLLGQEEKRPFVEEADRLRQVHKKTHPNYKYQPRRR  165\n"+
"\n"+
"Query  180  KSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPT  239\n"+
"            K+   G+      TE+   S + I  A    SP  +  +    S    S  +Q PPT P \n"+
"Sbjct  166  KT---GRYPGNHGTEE---SASTIQGATVVFSPLKTENVGNCWS----SAATQCPPTTPN  215\n"+
"\n"+
"Query  240  T-----PKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEF  294\n"+
"                   KT  +     L  + R L +           +++  L+SD I N     V++ \n"+
"Sbjct  216  FRENGWKKTVDKSSSLGLHGQTRQLGQ----------TINVSGLTSDTICN-----VDDI  260\n"+
"\n"+
"Query  295  DQYLP  299\n"+
"            D+YLP\n"+
"Sbjct  261  DEYLP  265\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ETE59020.1<a name=ETE59020></a> Transcription factor SOX-8, partial [Ophiophagus hannah]  \n"+
"Length=292\n"+
"\n"+
" Score = 200 bits (508),  Expect = 2e-57, Method: Compositional matrix adjust.\n"+
" Identities = 155/376 (41%), Positives = 194/376 (52%), Gaps = 105/376 (28%)\n"+
"\n"+
"Query  145  LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIF  204\n"+
"            LL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRK                        \n"+
"Sbjct  11   LLSENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKR-----------------------  47\n"+
"\n"+
"Query  205  KALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPG-KADLKREGRPLPEGG  263\n"+
"                                     Q  GPPTPPTTPKTD+ PG K +LK EGR L E G\n"+
"Sbjct  48   -------------------------QPHGPPTPPTTPKTDLHPGSKQELKHEGRRLMESG  82\n"+
"\n"+
"Query  264  RQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGIS-  322\n"+
"            RQ  IDF +VDI ELSS+VI+N+E FD++EFDQYLP NGH  +PA+HGQ +  GSYG S \n"+
"Sbjct  83   RQN-IDFSNVDISELSSEVINNMEAFDIHEFDQYLPLNGHSAIPASHGQNSTAGSYGTSY  141\n"+
"\n"+
"Query  323  --STAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAH  380\n"+
"              S  ++   +  +W  K  A                                       \n"+
"Sbjct  142  PHSANSSTGGSSQIWTHKSPAS--------------------------------------  163\n"+
"\n"+
"Query  381  TLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQ-  439\n"+
"               + SS     QR HIKTEQLSPSHYS+Q  +SP    Y  +     + +  P + +  \n"+
"Sbjct  164  --ASPSSSESSHQRPHIKTEQLSPSHYSDQPHNSPTHSDYGSYTAQACATTVSPSSATGS  221\n"+
"\n"+
"Query  440  -----YDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHS  494\n"+
"                  DYTD Q SS+YY+  +G  + +Y  + Y + ++RP  TPI ++    SIP +HS\n"+
"Sbjct  222  FSSSPCDYTDLQ-SSNYYNPYSGYPSSIYQ-YPYFHSSRRPYATPILNSL---SIPPSHS  276\n"+
"\n"+
"Query  495  PQ-HWEQPVYTQLTRP  509\n"+
"            P  +W+QPVYT LTRP\n"+
"Sbjct  277  PTANWDQPVYTTLTRP  292\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ABB45787.1<a name=ABB45787></a> transcription factor sox9, partial [Oreochromis aureus]  \n"+
"Length=135\n"+
"\n"+
" Score = 191 bits (485),  Expect = 3e-56, Method: Compositional matrix adjust.\n"+
" Identities = 113/138 (82%), Positives = 118/138 (86%), Gaps = 8/138 (6%)\n"+
"\n"+
"Query  168  DHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKAL-QADSPHSSSGMSEVHSPGE  226\n"+
"            DHPDYKYQPRRRKSVKNGQ+E E+ +EQTHISPNAIFKAL QAD P SS  M EVHSPGE\n"+
"Sbjct  1    DHPDYKYQPRRRKSVKNGQSEGEDGSEQTHISPNAIFKALQQADPPASS--MGEVHSPGE  58\n"+
"\n"+
"Query  227  HSGQSQGPPTPPTTPKTDVQPGKADLKREG--RPLPE--GGRQPPIDFRDVDIGELSSDV  282\n"+
"            HSG SQGPPTPPTTPKTDV  GK DLKRE   R LP+  GGRQ  IDFRDVDIGELSSDV\n"+
"Sbjct  59   HSG-SQGPPTPPTTPKTDVSSGKVDLKREVGLRSLPDGPGGRQLNIDFRDVDIGELSSDV  117\n"+
"\n"+
"Query  283  ISNIETFDVNEFDQYLPP  300\n"+
"            IS+IETFDVNEFDQYLPP\n"+
"Sbjct  118  ISHIETFDVNEFDQYLPP  135\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAJ76658.1<a name=BAJ76658></a> transcription factor SoxE, partial [Branchiostoma belcheri]  \n"+
"\n"+
"Length=368\n"+
"\n"+
" Score = 198 bits (504),  Expect = 5e-56, Method: Compositional matrix adjust.\n"+
" Identities = 174/443 (39%), Positives = 208/443 (47%), Gaps = 124/443 (28%)\n"+
"\n"+
"Query  116  AQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQ  175\n"+
"            AQAARRKLADQYPHLHNAELSKTLGKLWR+LNE EKRPF+EEAERLRVQHKKDHPDYKYQ\n"+
"Sbjct  1    AQAARRKLADQYPHLHNAELSKTLGKLWRMLNEDEKRPFIEEAERLRVQHKKDHPDYKYQ  60\n"+
"\n"+
"Query  176  PRRRKSVKNGQAEAEEA-TEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGP  234\n"+
"            PRRRK+ K  Q   +EA +E + IS N IFKALQA+SP  S    E HSP +  G S   \n"+
"Sbjct  61   PRRRKNSKANQGSGDEAGSEPSPISANTIFKALQAESPTGS----EPHSPEDMKGPSPHD  116\n"+
"\n"+
"Query  235  PTPPTTPKTDVQPG-----KADLKREGRPLPEGGRQPP----------------------  267\n"+
"             +   TP +   P      K D         +G ++                        \n"+
"Sbjct  117  GSVGVTPSSQAPPTPPTTPKQDQGMTALKAADGMKRDSTSNTLTAIHRDGPHHHHHHPQG  176\n"+
"\n"+
"Query  268  -----IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATH--GQVTYTGSYG  320\n"+
"                 IDF +VDIG L  DV+S++E+FDV EFDQYLPPNGHP   + H      YT    \n"+
"Sbjct  177  HGHPNIDFSNVDIGPL--DVMSSMESFDVEEFDQYLPPNGHPASASGHHPSHPAYTSYSQ  234\n"+
"\n"+
"Query  321  ISSTAATPASAGHV-WMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQA  379\n"+
"            +SS++AT        WM+KQ   P                                    \n"+
"Sbjct  235  MSSSSATTTVTSSSSWMAKQNTSP------------------------------------  258\n"+
"\n"+
"Query  380  HTLTTLSSEPGQSQRTHIKTEQ-------------LSPSHYSEQQQHSPQQIAYSPFNLP  426\n"+
"                    +  Q QR  +K EQ                S Y+ Q Q+S  Q  +SP   P\n"+
"Sbjct  259  -------RDNSQEQRLPVKMEQEHLPPPPPQYTPHPPASSYNYQPQYSSYQ--HSPPR-P  308\n"+
"\n"+
"Query  427  HYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGV  486\n"+
"             Y+   PP    Q  Y+ H  SSS           +   + YM P QR +Y  +A   G \n"+
"Sbjct  309  QYTDYPPPAHSPQQFYSPHPTSSS-----------IPPPYNYMAPPQRSLYPTVA---GA  354\n"+
"\n"+
"Query  487  PSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            PS         WE P YTQL RP\n"+
"Sbjct  355  PST--------WE-PSYTQLARP  368\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012860937.1<a name=XP_012860937></a> PREDICTED: transcription factor SOX-8 [Echinops telfairi]  \n"+
"Length=603\n"+
"\n"+
" Score = 204 bits (520),  Expect = 5e-56, Method: Compositional matrix adjust.\n"+
" Identities = 156/389 (40%), Positives = 200/389 (51%), Gaps = 83/389 (21%)\n"+
"\n"+
"Query  145  LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATE--QTHISPNA  202\n"+
"            LL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS+K G  +A+   E          \n"+
"Sbjct  274  LLSETEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSMKPGHGDADSGAELGHPPGGGGG  333\n"+
"\n"+
"Query  203  IFKALQADSPHSSSGMSEVHSPGEHSGQSQG-------PPTPPTTPKTDVQPGKADLKRE  255\n"+
"            I+KA         +G+S+ H  GEH+GQ+ G       P T P  P       K +LK E\n"+
"Sbjct  334  IYKA--------DAGLSDGHHHGEHAGQTHGPPTPPTTPKTDPHHPGGGGGSSKQELKLE  385\n"+
"\n"+
"Query  256  GRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPA-------  308\n"+
"            GR + +GGRQ  IDF +VDI ELSS+VISN++ FDV+EFDQYLP NGH  + A       \n"+
"Sbjct  386  GRRVVDGGRQ-NIDFSNVDISELSSEVISNMDAFDVHEFDQYLPLNGHSVLAAEPSQAAA  444\n"+
"\n"+
"Query  309  THGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQ  368\n"+
"            +          G +   A+P     VW  K                     P   +A P \n"+
"Sbjct  445  SSFSSASYSPAGAAGLGASP-----VWAHKG--------------------PSSASASPT  479\n"+
"\n"+
"Query  369  QPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQ-QQHSPQQIAYSPFNLPH  427\n"+
"            +  A                    QR HIKTEQLSPSHYS+Q    SP +  +  ++   \n"+
"Sbjct  480  EAGA--------------------QRPHIKTEQLSPSHYSDQAHSSSPGRAEFGSYSAQA  519\n"+
"\n"+
"Query  428  YSPSYPP------ITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIA  481\n"+
"               +  P       + SQ DYTD Q +S YY    G  + LY  + Y + ++RP  +P+ \n"+
"Sbjct  520  CVATAAPGVATGSFSGSQCDYTDLQ-ASGYYGTYPGYPSSLY-QYPYFHSSRRPYASPLL  577\n"+
"\n"+
"Query  482  DTSGVPSIPQTHSP-QHWEQPVYTQLTRP  509\n"+
"            +  G+ S+P  HSP  +WEQPVYT LTRP\n"+
"Sbjct  578  N--GL-SVPTAHSPTSNWEQPVYTTLTRP  603\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KTF90817.1<a name=KTF90817></a> hypothetical protein cypCar_00015203 [Cyprinus carpio]  \n"+
"Length=369\n"+
"\n"+
" Score = 196 bits (497),  Expect = 6e-55, Method: Compositional matrix adjust.\n"+
" Identities = 167/371 (45%), Positives = 204/371 (55%), Gaps = 82/371 (22%)\n"+
"\n"+
"Query  145  LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIF  204\n"+
"            LL E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK GQ+E +   +   ++P+ ++\n"+
"Sbjct  75   LLTENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKPGQSEPDPGAD---LTPH-MY  130\n"+
"\n"+
"Query  205  KALQADSPHSSSGMSEVHSPG----EHSGQSQGPPTPPTTPKTDV-QPGKADLKREGRPL  259\n"+
"            KA          GM  +  P     +H+GQ  GPPTPPTTPKTD+   GK D K EGR L\n"+
"Sbjct  131  KA--------ELGMGRLPGPSDHITDHTGQPHGPPTPPTTPKTDLHHGGKPDPKHEGRRL  182\n"+
"\n"+
"Query  260  PEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSY  319\n"+
"             +G RQ  IDF +VDI ELS+DVISN+E FDV+EFDQYLPP+GH G  A  GQ   +   \n"+
"Sbjct  183  LDGTRQ-NIDFSNVDISELSTDVISNMEAFDVHEFDQYLPPSGHAGA-APDGQSASS---  237\n"+
"\n"+
"Query  320  GISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQA  379\n"+
"              +S  + PAS+G  W  K                               P A  +  Q \n"+
"Sbjct  238  -YASPYSHPASSGASWSRK------------------------------GPVASAEASQ-  265\n"+
"\n"+
"Query  380  HTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQ  439\n"+
"                          R  IKTEQLSPSHYSE   HSP+   YS       S S+       \n"+
"Sbjct  266  -------------HRARIKTEQLSPSHYSE---HSPEYGVYSTHGSSAASASF------T  303\n"+
"\n"+
"Query  440  YDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQ-HW  498\n"+
"             DYTD Q SS YY       +GLY  + Y + ++RP  + I +  G+ SIP +HSP   W\n"+
"Sbjct  304  SDYTDLQ-SSGYYGPYTSYPSGLYQ-YPYFHSSRRPYGSNILN--GL-SIPPSHSPSAGW  358\n"+
"\n"+
"Query  499  EQPVYTQLTRP  509\n"+
"            +QPVYT L+RP\n"+
"Sbjct  359  DQPVYTTLSRP  369\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAO39392.1<a name=AAO39392></a> transcription factor sox-9, partial [Orycteropus afer]  \n"+
"Length=205\n"+
"\n"+
" Score = 189 bits (479),  Expect = 2e-54, Method: Compositional matrix adjust.\n"+
" Identities = 136/142 (96%), Positives = 136/142 (96%), Gaps = 0/142 (0%)\n"+
"\n"+
"Query  270  FRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPA  329\n"+
"            FRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATH QVTYTGSYGISSTAATPA\n"+
"Sbjct  1    FRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHSQVTYTGSYGISSTAATPA  60\n"+
"\n"+
"Query  330  SAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEP  389\n"+
"            SAGHVWMSKQQ PPPPPQQPPQAP APQAPPQP AAPPQ PAAPPQQ QAHTLTTLSSEP\n"+
"Sbjct  61   SAGHVWMSKQQGPPPPPQQPPQAPQAPQAPPQPPAAPPQPPAAPPQQQQAHTLTTLSSEP  120\n"+
"\n"+
"Query  390  GQSQRTHIKTEQLSPSHYSEQQ  411\n"+
"            GQSQRTHIKTEQLSPSHYSEQQ\n"+
"Sbjct  121  GQSQRTHIKTEQLSPSHYSEQQ  142\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017780683.1<a name=XP_017780683></a> PREDICTED: transcription factor Sox-9-A-like [Nicrophorus vespilloides] \n"+
" \n"+
"Length=399\n"+
"\n"+
" Score = 195 bits (495),  Expect = 3e-54, Method: Compositional matrix adjust.\n"+
" Identities = 111/230 (48%), Positives = 137/230 (60%), Gaps = 30/230 (13%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I +AV++VLKGYDWTLVP+  +   S K K HVKRPMNAFMVWAQAARRKLA+QYP LHN\n"+
"Sbjct  59   INDAVTKVLKGYDWTLVPIATKA-SSDKRKLHVKRPMNAFMVWAQAARRKLAEQYPQLHN  117\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKN---GQAEA  189\n"+
"            AELSKTLGKLWR+L++++K+PF+EEAERLRV HK++HPDYKYQPRRRK  K+        \n"+
"Sbjct  118  AELSKTLGKLWRVLSDNDKKPFIEEAERLRVIHKREHPDYKYQPRRRKQNKSPAGSDQSG  177\n"+
"\n"+
"Query  190  EEATEQTHISPNAIFKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPG  248\n"+
"                   +  PN  F++L Q DSP S    S        S  S  P +PP   +    P \n"+
"Sbjct  178  GGHQGGGNHGPNMTFRSLKQEDSPMSLRSNST-------SPSSCDPHSPPANHQQIRTPS  230\n"+
"\n"+
"Query  249  KADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYL  298\n"+
"              D            + P +DF D++      D        D N+ DQYL\n"+
"Sbjct  231  CLD------------QSPAVDFGDIEQASFIPD------DLDSNDLDQYL  262\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AEH57091.1<a name=AEH57091></a> SoxE, partial [Bugula neritina]  \n"+
"Length=250\n"+
"\n"+
" Score = 189 bits (481),  Expect = 5e-54, Method: Compositional matrix adjust.\n"+
" Identities = 87/114 (76%), Positives = 97/114 (85%), Gaps = 2/114 (2%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I+EAVS VLKGYDW+LV    + N   + KPH+KRPMNAFMVWAQAARRKLADQYP LHN\n"+
"Sbjct  32   IQEAVSNVLKGYDWSLVTSQSKAN--ERRKPHIKRPMNAFMVWAQAARRKLADQYPQLHN  89\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQ  186\n"+
"            AELSKTLGKLW+LLN SEK+PF+EEAE+LR QHKKDHPDYKYQPRRR+S    Q\n"+
"Sbjct  90   AELSKTLGKLWKLLNNSEKKPFIEEAEKLRKQHKKDHPDYKYQPRRRRSNAKAQ  143\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACU12298.1<a name=ACU12298></a> Sox9 isoform 2, partial [Mus musculus]  \n"+
"Length=171\n"+
"\n"+
" Score = 186 bits (471),  Expect = 1e-53, Method: Compositional matrix adjust.\n"+
" Identities = 87/91 (96%), Positives = 88/91 (97%), Gaps = 0/91 (0%)\n"+
"\n"+
"Query  248  GKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP  307\n"+
"            GK DLKREGRPL EGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP\n"+
"Sbjct  1    GKVDLKREGRPLAEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP  60\n"+
"\n"+
"Query  308  ATHGQVTYTGSYGISSTAATPASAGHVWMSK  338\n"+
"            ATHGQVTYTGSYGISSTA TPA+AGHVWMSK\n"+
"Sbjct  61   ATHGQVTYTGSYGISSTAPTPATAGHVWMSK  91\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ALG35687.1<a name=ALG35687></a> SoxE [Lytechinus variegatus]  \n"+
"Length=499\n"+
"\n"+
" Score = 196 bits (497),  Expect = 1e-53, Method: Compositional matrix adjust.\n"+
" Identities = 132/317 (42%), Positives = 175/317 (55%), Gaps = 31/317 (10%)\n"+
"\n"+
"Query  63   ESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRK  122\n"+
"            E    +F   I++AVS+VL GYDW++V +P R   + K KPH+KRPMNAFMVWAQAAR+K\n"+
"Sbjct  55   EGAATQFSPSIKDAVSRVLNGYDWSVVAIPTRTGPNGKRKPHIKRPMNAFMVWAQAARKK  114\n"+
"\n"+
"Query  123  LADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSV  182\n"+
"            L +QYP LHNAELSKTLGKLWRLL++ EK+PF+EEAERLR QHKKD+PDYKYQPRRR   \n"+
"Sbjct  115  LGNQYPQLHNAELSKTLGKLWRLLSDKEKQPFIEEAERLRQQHKKDYPDYKYQPRRRNKN  174\n"+
"\n"+
"Query  183  KNGQAEA-----EEAT------EQTHISPNAIFKALQAD--SPHSSSGMSEVHSPGEHSG  229\n"+
"             N   +        +T         H+S  A+  A+  +  +  +    +E         \n"+
"Sbjct  175  DNSNTKKPCPPNNRSTLVPSPDSSNHVSTKALLSAMVGEEITEANMKERTEKLGMMMGGA  234\n"+
"\n"+
"Query  230  QSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETF  289\n"+
"              QGPPTPPTTPK D+   + + KR+   L +   + P+DF  VD+ +   D++  +E F\n"+
"Sbjct  235  GGQGPPTPPTTPKNDLDCTRPN-KRQKYSL-KVKTEMPVDFAGVDVRDFGGDIMG-MEEF  291\n"+
"\n"+
"Query  290  DVNEFDQYL-----PPNGHPGVPATHGQVTYT---------GSYGISSTAATPASAGHVW  335\n"+
"               E DQY+            +P   G V  T          SY +S+   T +S G  W\n"+
"Sbjct  292  SSEELDQYIVQTIASVTASQPMPCQQGMVRQTCAMPPFTTHSSYPMSN-VNTQSSNGRQW  350\n"+
"\n"+
"Query  336  MSKQQAPPPPPQQPPQA  352\n"+
"            M  +  P      P QA\n"+
"Sbjct  351  MGGRHHPSGGNTSPLQA  367\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ALE14467.1<a name=ALE14467></a> transcription factor sox8, partial [Scophthalmus maximus]  \n"+
"Length=116\n"+
"\n"+
" Score = 183 bits (464),  Expect = 2e-53, Method: Compositional matrix adjust.\n"+
" Identities = 85/98 (87%), Positives = 92/98 (94%), Gaps = 0/98 (0%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLL+ESEKRPFV+EAE\n"+
"Sbjct  1    KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLSESEKRPFVDEAE  60\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTH  197\n"+
"            RLRVQHKKDHPDYKYQPRRRK+VK GQ++++   E  H\n"+
"Sbjct  61   RLRVQHKKDHPDYKYQPRRRKNVKPGQSDSDSGAELAH  98\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_018331741.1<a name=XP_018331741></a> PREDICTED: transcription factor SOX-9-like [Agrilus planipennis] \n"+
" \n"+
"Length=408\n"+
"\n"+
" Score = 192 bits (488),  Expect = 3e-53, Method: Compositional matrix adjust.\n"+
" Identities = 130/292 (45%), Positives = 160/292 (55%), Gaps = 39/292 (13%)\n"+
"\n"+
"Query  52   TFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNA  111\n"+
"            T P+  P  ++ S  DK    I EAV++VLKGYDWTLVP+  +   S K K HVKRPMNA\n"+
"Sbjct  38   TSPQRSPTSEEHSSIDKTE--INEAVTKVLKGYDWTLVPIATKA-SSDKRKLHVKRPMNA  94\n"+
"\n"+
"Query  112  FMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPD  171\n"+
"            FMVWAQAARRKLADQYP LHNAELSKTLGKLWRLL++++K+PFVEEA+RLR+ HK+ HPD\n"+
"Sbjct  95   FMVWAQAARRKLADQYPQLHNAELSKTLGKLWRLLSDNDKKPFVEEADRLRIIHKRKHPD  154\n"+
"\n"+
"Query  172  YKYQPRRRKSVKNGQAEAEEATEQTHISPNAIF-KALQAD--SPHSSSGMSEVHSPGEHS  228\n"+
"            YKYQPRRRK     Q    ++  Q     N  F ++L+ +  SP S    S        S\n"+
"Sbjct  155  YKYQPRRRK-----QKGPNDSIHQLPHGSNVTFSRSLKQEESSPCSPRRHSSTSPSSCSS  209\n"+
"\n"+
"Query  229  GQSQGPPTPPTTPK-TDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIE  287\n"+
"                   TP T  + TDV     D  R    LPE        F +  I E         +\n"+
"Sbjct  210  QPHSPSITPHTFKQCTDVSNNSIDFNR----LPE--------FDNTYITE---------D  248\n"+
"\n"+
"Query  288  TFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQ  339\n"+
"              D N+ DQYLP      V   + Q  Y  SY I   +    S  + + SK+\n"+
"Sbjct  249  CLDSNDLDQYLP------VEHGYQQNIYHDSYVIRRVSEDDESNNNNYKSKR  294\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EHH31284.1<a name=EHH31284></a> Transcription factor SOX-8, partial [Macaca mulatta]  \n"+
"Length=305\n"+
"\n"+
" Score = 189 bits (480),  Expect = 3e-53, Method: Compositional matrix adjust.\n"+
" Identities = 157/369 (43%), Positives = 198/369 (54%), Gaps = 68/369 (18%)\n"+
"\n"+
"Query  145  LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQT-HISPNAI  203\n"+
"            LL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS K GQ++++   E   H    A+\n"+
"Sbjct  1    LLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSTKAGQSDSDSGAELGPHPGGGAV  60\n"+
"\n"+
"Query  204  FKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKA--DLKREGRPLPE  261\n"+
"            +KA         SG+ + H  G+H+GQ+ GPPTPPTTPKT++Q   A  +LK EGR   +\n"+
"Sbjct  61   YKA--------ESGLGDAHHHGDHTGQTHGPPTPPTTPKTELQQAGAKPELKLEGRRPAD  112\n"+
"\n"+
"Query  262  GGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGI  321\n"+
"             GRQ  IDF +VDI ELSS+V+  ++ FD +EFDQYLP  G    P   GQ  Y G+Y  \n"+
"Sbjct  113  SGRQ-NIDFSNVDISELSSEVMGTMDAFDAHEFDQYLPLGGP--APPEPGQA-YGGAY--  166\n"+
"\n"+
"Query  322  SSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHT  381\n"+
"                   A A  VW  K                AP A   P    P              \n"+
"Sbjct  167  -----FHAGASPVWAHKS---------------APSASASPTETGP--------------  192\n"+
"\n"+
"Query  382  LTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYD  441\n"+
"                       +R  IKTEQ SP HY +Q + SP   + S       +    P T +Q D\n"+
"Sbjct  193  -----------RRLQIKTEQPSPGHYGDQPRGSPDYGSCSGQASAAPAAPAGPFTGAQGD  241\n"+
"\n"+
"Query  442  YTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP-QHWEQ  500\n"+
"            Y D Q +SSYY    G   GLY    + +P +RP  +P+ ++    ++P +HSP  HW+Q\n"+
"Sbjct  242  YGDLQ-ASSYYGAYPGYAPGLYQYPCFHSP-RRPYASPLLNSL---ALPPSHSPTSHWDQ  296\n"+
"\n"+
"Query  501  PVYTQLTRP  509\n"+
"            PVYT LTRP\n"+
"Sbjct  297  PVYTTLTRP  305\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012262254.1<a name=XP_012262254></a> PREDICTED: putative uncharacterized protein DDB_G0282133 [Athalia \n"+
"rosae]  \n"+
"Length=745\n"+
"\n"+
" Score = 199 bits (506),  Expect = 4e-53, Method: Compositional matrix adjust.\n"+
" Identities = 105/183 (57%), Positives = 128/183 (70%), Gaps = 9/183 (5%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV++VLKGYDWTLVP+  + +G  K   HVKRPMNAFMVWAQAARR+LADQYP LHN\n"+
"Sbjct  191  ISAAVAKVLKGYDWTLVPVATKGSGD-KRAAHVKRPMNAFMVWAQAARRRLADQYPQLHN  249\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA  192\n"+
"            AELSKTLGKLWRLL+ES+K+PFVEEAERLRV HK++HPDYKYQPRRRK   NG  E   +\n"+
"Sbjct  250  AELSKTLGKLWRLLSESDKKPFVEEAERLRVIHKREHPDYKYQPRRRKQNGNGIRENSPS  309\n"+
"\n"+
"Query  193  TEQTHIS---PNAIFKALQADSPHSSSGMSEVHSP-----GEHSGQSQGPPTPPTTPKTD  244\n"+
"              Q++++     + FK  ++ SP S +    V        G  S QS    +PPTTP+  \n"+
"Sbjct  310  RSQSNVTFSVSRSSFKQEESSSPASGNIRGHVQGVPPGIQGPTSPQSTKSSSPPTTPRHG  369\n"+
"\n"+
"Query  245  VQP  247\n"+
"            + P\n"+
"Sbjct  370  LSP  372\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAR45483.1<a name=BAR45483></a> SRY-box containing protein 9, partial [Seriola quinqueradiata] \n"+
" \n"+
"Length=168\n"+
"\n"+
" Score = 183 bits (465),  Expect = 9e-53, Method: Compositional matrix adjust.\n"+
" Identities = 118/205 (58%), Positives = 134/205 (65%), Gaps = 47/205 (23%)\n"+
"\n"+
"Query  315  YTGSYGIS-STAATPASAG-HVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAA  372\n"+
"            YTGSYGIS S+    AS G H WMSKQQ                                \n"+
"Sbjct  1    YTGSYGISGSSVGQAASVGAHTWMSKQQQ-------------------------------  29\n"+
"\n"+
"Query  373  PPQQPQAHTLTTLSSEPGQSQRTH-----IKTEQLSPSHYSEQQQHSPQQIAYSPFNLPH  427\n"+
"                 Q H+LTTL     Q Q+       IKTEQLSPSHYSEQQ  SPQ I Y  FNL H\n"+
"Sbjct  30   -----QQHSLTTLGGGGEQGQQGQQRTTQIKTEQLSPSHYSEQQG-SPQHITYGSFNLQH  83\n"+
"\n"+
"Query  428  YSPS-YPPITRSQYDYTDHQN-SSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSG  485\n"+
"            YSPS YP ITR+QYDY+DHQ  ++SYYSHAAGQG+GLYSTF+YM+P+QRPMYTPIADT+G\n"+
"Sbjct  84   YSPSSYPSITRAQYDYSDHQGGANSYYSHAAGQGSGLYSTFSYMSPSQRPMYTPIADTTG  143\n"+
"\n"+
"Query  486  VPSIPQTHSPQHWE-QPVYTQLTRP  509\n"+
"            VPS+PQTHSPQHW+ QP+YTQL+RP\n"+
"Sbjct  144  VPSVPQTHSPQHWDQQPIYTQLSRP  168\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">4EUW_A<a name=4EUW_A></a> Chain A, Crystal Structure Of A Hmg Domain Of Transcription Factor \n"+
"Sox-9 Bound To Dna (Sox-9DNA) FROM HOMO SAPIENS AT 2.77 \n"+
"A RESOLUTION  \n"+
"Length=106\n"+
"\n"+
" Score = 179 bits (455),  Expect = 3e-52, Method: Compositional matrix adjust.\n"+
" Identities = 84/84 (100%), Positives = 84/84 (100%), Gaps = 0/84 (0%)\n"+
"\n"+
"Query  98   SSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEE  157\n"+
"            SSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEE\n"+
"Sbjct  23   SSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEE  82\n"+
"\n"+
"Query  158  AERLRVQHKKDHPDYKYQPRRRKS  181\n"+
"            AERLRVQHKKDHPDYKYQPRRRKS\n"+
"Sbjct  83   AERLRVQHKKDHPDYKYQPRRRKS  106\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAK50634.1<a name=AAK50634></a> sox9 protein, partial [Oryzias latipes]  \n"+
"Length=207\n"+
"\n"+
" Score = 183 bits (465),  Expect = 3e-52, Method: Compositional matrix adjust.\n"+
" Identities = 137/244 (56%), Positives = 147/244 (60%), Gaps = 45/244 (18%)\n"+
"\n"+
"Query  169  HPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQ-ADSPHSSSGMSEVHSPGEH  227\n"+
"            HPDYKYQPRRRKSVK+G +EAE+  E  HIS NAIFKALQ ADSP +S  M EVHSP EH\n"+
"Sbjct  1    HPDYKYQPRRRKSVKSGGSEAEDGGE--HISTNAIFKALQQADSPAAS--MGEVHSPAEH  56\n"+
"\n"+
"Query  228  SGQSQGPPTPPTTPKTDVQPGKADLKREG--RPLPEG--GRQPPIDFRDVDIGELSSDVI  283\n"+
"            SG SQ PPTPPTTPKTD    K DLKREG  RPLP+G  GRQ  IDFRDVDIGELSS VI\n"+
"Sbjct  57   SG-SQAPPTPPTTPKTDCS-AKMDLKREGGLRPLPDGAPGRQLNIDFRDVDIGELSSGVI  114\n"+
"\n"+
"Query  284  SNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPP  343\n"+
"            S+IETFDV+EFDQYLPPNGHPG                    A P S            P\n"+
"Sbjct  115  SHIETFDVHEFDQYLPPNGHPG--------------------AAPGSTA----------P  144\n"+
"\n"+
"Query  344  PPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQS---QRTHIKTE  400\n"+
"                       AP   PQ    P     A  QQ Q H+LT L +  G     +RT IKTE\n"+
"Sbjct  145  VSYSGSYSISGAPPLSPQAGGGPAWMAKAHSQQ-QQHSLTPLGTSGGSEAALRRTQIKTE  203\n"+
"\n"+
"Query  401  QLSP  404\n"+
"            QLSP\n"+
"Sbjct  204  QLSP  207\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015521624.1<a name=XP_015521624></a> PREDICTED: transcription factor Sox-9-B-like [Neodiprion lecontei] \n"+
" \n"+
"Length=497\n"+
"\n"+
" Score = 191 bits (486),  Expect = 5e-52, Method: Compositional matrix adjust.\n"+
" Identities = 122/283 (43%), Positives = 154/283 (54%), Gaps = 63/283 (22%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV++VLKGYDWTLVP+  + +G  K   HVKRPMNAFMVWAQAARR+LADQYP LHN\n"+
"Sbjct  62   ISAAVAKVLKGYDWTLVPVATKGSGD-KRAAHVKRPMNAFMVWAQAARRRLADQYPQLHN  120\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA  192\n"+
"            AELSKTLGKLWRLL+ES+K+PFVEEAERLRV HK++HPDYKYQPRRRK   +   +    \n"+
"Sbjct  121  AELSKTLGKLWRLLSESDKKPFVEEAERLRVIHKREHPDYKYQPRRRKQNGSNGRDNSPT  180\n"+
"\n"+
"Query  193  TEQTHISPNAIFKAL-QADSPHSSSGMSEVHSPGEHSGQSQGPP----------TPPTTP  241\n"+
"              Q++++ +    +  Q DS     G+    SP   SG S  PP          TPPTTP\n"+
"Sbjct  181  RSQSNVTFSVSRSSFKQEDSRSPVGGLQGPTSP--QSGISSSPPTTPRQGLSPLTPPTTP  238\n"+
"\n"+
"Query  242  KT-----------------------DVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGEL  278\n"+
"            +                        D   G +    EG P   GG    +D R +++GE \n"+
"Sbjct  239  REQHYANMQGNPHQQNNSTIPLYHHDQSSGASSATCEG-PQQHGG----VDLRYIEVGEC  293\n"+
"\n"+
"Query  279  ----------SSDVISNIETFDV-----------NEFDQYLPP  300\n"+
"                       S+ +  +   ++           +E DQYLPP\n"+
"Sbjct  294  LPVEDGHLTTLSNTLGGVAGLNLPLALHECEVESSELDQYLPP  336\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012866732.1<a name=XP_012866732></a> PREDICTED: transcription factor SOX-8 [Dipodomys ordii]  \n"+
"Length=438\n"+
"\n"+
" Score = 189 bits (481),  Expect = 6e-52, Method: Compositional matrix adjust.\n"+
" Identities = 158/379 (42%), Positives = 204/379 (54%), Gaps = 67/379 (18%)\n"+
"\n"+
"Query  145  LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIF  204\n"+
"            LL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK G+++++   E        ++\n"+
"Sbjct  113  LLSETEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKPGRSDSDSGPELGQHPGGVLY  172\n"+
"\n"+
"Query  205  KALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPG----KADLKREGRPLP  260\n"+
"            KA         S +S+    G+H+G + GPPTPPTTPKTD+ PG    + +LK EGR L \n"+
"Sbjct  173  KA--------DSVLSDAPHHGDHTGHTHGPPTPPTTPKTDLHPGGTGARQELKLEGRRLA  224\n"+
"\n"+
"Query  261  EGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYT-GSY  319\n"+
"            + GRQ  IDF +VDI ELSS+VISN++ FDV+EFDQYLP +GH   PA   Q T   GSY\n"+
"Sbjct  225  DSGRQ-NIDFSNVDISELSSEVISNMDAFDVHEFDQYLPLDGHAAPPAEPSQATAAGGSY  283\n"+
"\n"+
"Query  320  -GISSTAATPASAGH--VWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQ  376\n"+
"             G S  A+ PAS G   VW  K  +          A P    PP+P              \n"+
"Sbjct  284  RGTSYPASGPASVGASPVWAHKGAS-------SASASPTEAGPPRP--------------  322\n"+
"\n"+
"Query  377  PQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNL------PHYSP  430\n"+
"                               HIKTEQLSPS Y +Q   SP +  Y  ++          + \n"+
"Sbjct  323  -------------------HIKTEQLSPSRYGDQPHGSPGRSDYGSYSTQAGVAAAAPAA  363\n"+
"\n"+
"Query  431  SYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIP  490\n"+
"            +      +Q DYTD Q S+ Y  +       LY  + Y + ++RP  +P+ +  G+   P\n"+
"Sbjct  364  AASSFASAQCDYTDLQTSNYYSPYPG-YPPSLYQ-YPYFHSSRRPYASPLLN--GLSMPP  419\n"+
"\n"+
"Query  491  QTHSPQHWEQPVYTQLTRP  509\n"+
"                  +W+QPVYT LTRP\n"+
"Sbjct  420  SHSPSSNWDQPVYTTLTRP  438\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015833813.1<a name=XP_015833813></a> PREDICTED: transcription factor Sox-10 [Tribolium castaneum] \n"+
" \n"+
"Length=385\n"+
"\n"+
" Score = 187 bits (475),  Expect = 1e-51, Method: Compositional matrix adjust.\n"+
" Identities = 108/227 (48%), Positives = 136/227 (60%), Gaps = 25/227 (11%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I +AV++VL+GYDWTLVP+  +   S K K HVKRPMNAFMVWAQAARRKLADQYP LHN\n"+
"Sbjct  51   INDAVTKVLQGYDWTLVPIASKA-ASDKRKLHVKRPMNAFMVWAQAARRKLADQYPQLHN  109\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA  192\n"+
"            AELSKTLGKLWRLL++ +K+PF+EEAERLRV HK++HPDYKYQPRRRK  K+      + \n"+
"Sbjct  110  AELSKTLGKLWRLLSDVDKKPFIEEAERLRVIHKREHPDYKYQPRRRKQNKSPGDSMLQL  169\n"+
"\n"+
"Query  193  TEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADL  252\n"+
"                +++ +   K  Q DSP  S       SP   S Q   P   P T ++ ++    D \n"+
"Sbjct  170  PHGQNVTFSRSLK--QEDSP-CSPRSHSSTSPSTCSSQPHSPAIQPQTLRSCLEQHNLDF  226\n"+
"\n"+
"Query  253  KREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLP  299\n"+
"             R                 ++D   +S D I N      ++ DQY P\n"+
"Sbjct  227  NR---------------LSEIDNSYISEDCIDN------SDLDQYFP  252\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002186765.3<a name=XP_002186765></a> PREDICTED: transcription factor SOX-9-like, partial [Taeniopygia \n"+
"guttata]  \n"+
"Length=168\n"+
"\n"+
" Score = 180 bits (456),  Expect = 1e-51, Method: Compositional matrix adjust.\n"+
" Identities = 122/206 (59%), Positives = 133/206 (65%), Gaps = 46/206 (22%)\n"+
"\n"+
"Query  311  GQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQP  370\n"+
"            GQVTYTGSYGIS  A TPA    VWM+KQQ P    +Q PQ                   \n"+
"Sbjct  2    GQVTYTGSYGISGAAGTPAG---VWMAKQQQPALGTEQGPQQQQQ---------------  43\n"+
"\n"+
"Query  371  AAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSP------FN  424\n"+
"                                Q QRTHIKTEQLSPSHYSEQQQHSPQQ           FN\n"+
"Sbjct  44   --------------------QQQRTHIKTEQLSPSHYSEQQQHSPQQQQQQQQLSYSSFN  83\n"+
"\n"+
"Query  425  LPHYSPSYPPITRSQYDYTDHQNSS-SYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADT  483\n"+
"            L HY  SYP I+R+QY+Y +HQ SS SYYSHA GQG+G+YSTF+YM+P QRPMYTPIADT\n"+
"Sbjct  84   LQHYGSSYPSISRAQYEYGEHQGSSGSYYSHA-GQGSGIYSTFSYMSPTQRPMYTPIADT  142\n"+
"\n"+
"Query  484  SGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            +GVPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  143  AGVPSIPQTHSPQHWEQPVYTQLTRP  168\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010143871.1<a name=XP_010143871></a> PREDICTED: transcription factor SOX-8-like, partial [Buceros \n"+
"rhinoceros silvestris]  \n"+
"Length=157\n"+
"\n"+
" Score = 179 bits (453),  Expect = 3e-51, Method: Compositional matrix adjust.\n"+
" Identities = 106/166 (64%), Positives = 125/166 (75%), Gaps = 9/166 (5%)\n"+
"\n"+
"Query  145  LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIF  204\n"+
"            LL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK GQ++++   E +H     I+\n"+
"Sbjct  1    LLSENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKAGQSDSDSGAELSHHGGTQIY  60\n"+
"\n"+
"Query  205  KALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGR  264\n"+
"            K   ADS     GM++ H  G+H GQ+ GPPTPPTTPKT      A+LK EGR L E GR\n"+
"Sbjct  61   K---ADS--GLGGMADSHHHGDHPGQTHGPPTPPTTPKT---DPGAELKHEGRRLVESGR  112\n"+
"\n"+
"Query  265  QPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATH  310\n"+
"            Q  IDF +VDI ELSS+VI+N+ETFDV+EFDQYLP NGH  +PA H\n"+
"Sbjct  113  Q-NIDFSNVDISELSSEVINNMETFDVHEFDQYLPLNGHATMPADH  157\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KGL96169.1<a name=KGL96169></a> Transcription factor SOX-8, partial [Charadrius vociferus]  \n"+
"Length=139\n"+
"\n"+
" Score = 177 bits (449),  Expect = 7e-51, Method: Compositional matrix adjust.\n"+
" Identities = 89/131 (68%), Positives = 103/131 (79%), Gaps = 7/131 (5%)\n"+
"\n"+
"Query  113  MVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDY  172\n"+
"            MVWAQAARRKLADQYPHLHNAELSKTLGKLWRLL+E+EKRPFVEEAERLRVQHKKDHPDY\n"+
"Sbjct  1    MVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLSENEKRPFVEEAERLRVQHKKDHPDY  60\n"+
"\n"+
"Query  173  KYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQ  232\n"+
"            KYQPRRRKSVK GQ++++   E +H +   I+K   ADS     GM+E H  G+H+G  +\n"+
"Sbjct  61   KYQPRRRKSVKAGQSDSDSGAELSHHAGTQIYK---ADS--GLGGMAESHHHGDHTG--K  113\n"+
"\n"+
"Query  233  GPPTPPTTPKT  243\n"+
"            G PT    P+ \n"+
"Sbjct  114  GSPTGKKNPQV  124\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006166311.2<a name=XP_006166311></a> PREDICTED: transcription factor SOX-10, partial [Tupaia chinensis] \n"+
" \n"+
"Length=365\n"+
"\n"+
" Score = 184 bits (468),  Expect = 1e-50, Method: Compositional matrix adjust.\n"+
" Identities = 127/272 (47%), Positives = 158/272 (58%), Gaps = 53/272 (19%)\n"+
"\n"+
"Query  227  HSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNI  286\n"+
"            H GQS GPPTPPTTPKT++Q GKAD KR+GR + EGG+ P IDF +VDIGE+S +V+SN+\n"+
"Sbjct  12   HPGQSHGPPTPPTTPKTELQSGKADPKRDGRSMGEGGK-PHIDFGNVDIGEISHEVMSNM  70\n"+
"\n"+
"Query  287  ETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPP  346\n"+
"            ETFDV E DQYLPPNGHPG    H        YG+ S  A  AS    W+SK    PP  \n"+
"Sbjct  71   ETFDVAELDQYLPPNGHPG----HVGSYSAAGYGLGSALAV-ASGHSAWISK----PPGV  121\n"+
"\n"+
"Query  347  QQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPS-  405\n"+
"              P  +P                                   PG   +  +KTE   P  \n"+
"Sbjct  122  ALPTVSP-----------------------------------PGVDAKAQVKTETAGPQG  146\n"+
"\n"+
"Query  406  --HYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLY  463\n"+
"              HY++Q   S  QIAY+  +LPHY  ++P I+R Q+DY+DHQ S  YY H +GQ +GLY\n"+
"Sbjct  147  PPHYTDQPSTS--QIAYTSLSLPHYGSAFPSISRPQFDYSDHQPSGPYYGH-SGQASGLY  203\n"+
"\n"+
"Query  464  STFTYMNPAQRPMYTPIADTSGVPSIPQTHSP  495\n"+
"            S F+YM P+QRP+YT I+D S  PS PQ+HSP\n"+
"Sbjct  204  SAFSYMGPSQRPLYTAISDPS--PSGPQSHSP  233\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015914452.1<a name=XP_015914452></a> PREDICTED: transcription factor SOX-8-like [Parasteatoda tepidariorum] \n"+
" \n"+
"Length=513\n"+
"\n"+
" Score = 188 bits (477),  Expect = 1e-50, Method: Compositional matrix adjust.\n"+
" Identities = 82/108 (76%), Positives = 94/108 (87%), Gaps = 0/108 (0%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I+ AVS+VL+ YDW+LV    R++   K K HVKRPMNAFMVWAQAARRKLADQYPHLHN\n"+
"Sbjct  50   IQAAVSKVLQSYDWSLVAKTSRLSSGDKRKSHVKRPMNAFMVWAQAARRKLADQYPHLHN  109\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AELSKTLGKLWR+L + EK+PF+EEAERLR +HKKD+PDYKYQPRRRK\n"+
"Sbjct  110  AELSKTLGKLWRVLGDDEKKPFIEEAERLRCKHKKDYPDYKYQPRRRK  157\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015783447.1<a name=XP_015783447></a> PREDICTED: transcription factor SOX-9-like isoform X1 [Tetranychus \n"+
"urticae]  \n"+
"Length=752\n"+
"\n"+
" Score = 192 bits (487),  Expect = 1e-50, Method: Compositional matrix adjust.\n"+
" Identities = 89/133 (67%), Positives = 103/133 (77%), Gaps = 1/133 (1%)\n"+
"\n"+
"Query  52   TFPKGEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNA  111\n"+
"            + PK   + K  +  D+    I +AV++VLKGYDWTLV    R   SSK K HVKRPMNA\n"+
"Sbjct  81   SVPKSTDNRKSSNHSDQLASSINDAVTKVLKGYDWTLVTTKSRPTTSSKLKIHVKRPMNA  140\n"+
"\n"+
"Query  112  FMVWAQAARRKLADQYPHLHNAELSKTLGKLW-RLLNESEKRPFVEEAERLRVQHKKDHP  170\n"+
"            FMVWAQAARRKL++QYPHLHNAELSKTLGKLW R+L + EK+PF+ EAERLR +HKKD P\n"+
"Sbjct  141  FMVWAQAARRKLSEQYPHLHNAELSKTLGKLWSRVLGDDEKKPFIAEAERLRFKHKKDFP  200\n"+
"\n"+
"Query  171  DYKYQPRRRKSVK  183\n"+
"            DYKYQPRRRK VK\n"+
"Sbjct  201  DYKYQPRRRKPVK  213\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014387411.1<a name=XP_014387411></a> PREDICTED: transcription factor SOX-1 [Myotis brandtii]  \n"+
"Length=269\n"+
"\n"+
" Score = 181 bits (459),  Expect = 2e-50, Method: Compositional matrix adjust.\n"+
" Identities = 78/106 (74%), Positives = 94/106 (89%), Gaps = 0/106 (0%)\n"+
"\n"+
"Query  69   FPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYP  128\n"+
"            FPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKP VKRPMNAFMVW++  RRK+A + P\n"+
"Sbjct  34   FPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPRVKRPMNAFMVWSRGQRRKMAQENP  93\n"+
"\n"+
"Query  129  HLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKY  174\n"+
"             +HN+E+SK LG  W++++E+EKRPF++EA+RLR  H K+HPDYKY\n"+
"Sbjct  94   KMHNSEISKRLGAEWKVMSEAEKRPFIDEAKRLRALHMKEHPDYKY  139\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAB71657.1<a name=AAB71657></a> SOX9, partial [Sus scrofa]  \n"+
"Length=84\n"+
"\n"+
" Score = 174 bits (441),  Expect = 2e-50, Method: Compositional matrix adjust.\n"+
" Identities = 84/84 (100%), Positives = 84/84 (100%), Gaps = 0/84 (0%)\n"+
"\n"+
"Query  225  GEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVIS  284\n"+
"            GEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVIS\n"+
"Sbjct  1    GEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVIS  60\n"+
"\n"+
"Query  285  NIETFDVNEFDQYLPPNGHPGVPA  308\n"+
"            NIETFDVNEFDQYLPPNGHPGVPA\n"+
"Sbjct  61   NIETFDVNEFDQYLPPNGHPGVPA  84\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013778136.1<a name=XP_013778136></a> PREDICTED: transcription factor Sox-8-like [Limulus polyphemus] \n"+
" \n"+
"Length=499\n"+
"\n"+
" Score = 186 bits (473),  Expect = 3e-50, Method: Compositional matrix adjust.\n"+
" Identities = 82/108 (76%), Positives = 94/108 (87%), Gaps = 0/108 (0%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I++AVS+VL  YDW+ V    R + + K KPHVKRPMNAFMVWAQAARRKLADQYPHLHN\n"+
"Sbjct  57   IQDAVSKVLDSYDWSQVAKSSRQSSADKRKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  116\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AELSKTLGKLWR+L + EK+PF++EAERLR +HKKDHPDYKYQPRRRK\n"+
"Sbjct  117  AELSKTLGKLWRVLGDDEKKPFIDEAERLRCKHKKDHPDYKYQPRRRK  164\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015783378.1<a name=XP_015783378></a> PREDICTED: transcription factor Sox-9-like [Tetranychus urticae] \n"+
" \n"+
"Length=717\n"+
"\n"+
" Score = 190 bits (483),  Expect = 4e-50, Method: Compositional matrix adjust.\n"+
" Identities = 86/120 (72%), Positives = 99/120 (83%), Gaps = 3/120 (3%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I +AV++VL GYDWTLV    R   ++K K HVKRPMNAFMVWAQAARRKLADQYPHLHN\n"+
"Sbjct  101  INDAVTKVLNGYDWTLVTTASRSASTAKLKIHVKRPMNAFMVWAQAARRKLADQYPHLHN  160\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA  192\n"+
"            AELSK+LGKLWR+L+E EK+PF+EEAERLR+ HK  HPDYKYQPRRRKS   G+ E+ E \n"+
"Sbjct  161  AELSKSLGKLWRVLSEEEKKPFMEEAERLRLIHKTAHPDYKYQPRRRKS---GKTESNEG  217\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014243400.1<a name=XP_014243400></a> PREDICTED: transcription factor Sox-8-like isoform X1 [Cimex \n"+
"lectularius]  \n"+
"Length=313\n"+
"\n"+
" Score = 181 bits (459),  Expect = 4e-50, Method: Compositional matrix adjust.\n"+
" Identities = 107/230 (47%), Positives = 143/230 (62%), Gaps = 13/230 (6%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I +AV++VL+GYDWTLVP+  +   S K K HVKRPMNAFMVWAQAARRKLADQYP LHN\n"+
"Sbjct  21   ISDAVAKVLRGYDWTLVPIATKTT-SDKKKTHVKRPMNAFMVWAQAARRKLADQYPQLHN  79\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA  192\n"+
"            AELSKTLGKLWRLL ++EK+PF+EEAERLRV HK+++PDYKYQPRRRK   NG+     A\n"+
"Sbjct  80   AELSKTLGKLWRLLGDAEKKPFIEEAERLRVIHKREYPDYKYQPRRRKGSSNGKP----A  135\n"+
"\n"+
"Query  193  TEQTHISPNAIFKALQADSPHSSSGMSEVHSP--GEHSGQSQGPPTPPTTPKTDVQPGKA  250\n"+
"             ++      A+   ++ +    SSG  E      G  +  +        T   + Q  ++\n"+
"Sbjct  136  NQRGSTGSYAMMGRVKEE---CSSGAEEGEDELLGPPTPPTTPNRHGGVTAFRNAQQYQS  192\n"+
"\n"+
"Query  251  DLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPP  300\n"+
"            + ++    +     Q  +    V+ G +S + + N+E  D  EF+QYL P\n"+
"Sbjct  193  NGQQHANEMAATCSQEVMGV--VNPG-MSLEELGNVEGVDCAEFEQYLHP  239\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017798537.1<a name=XP_017798537></a> PREDICTED: transcription factor SOX-9-like [Habropoda laboriosa] \n"+
" \n"+
"Length=394\n"+
"\n"+
" Score = 183 bits (464),  Expect = 7e-50, Method: Compositional matrix adjust.\n"+
" Identities = 119/277 (43%), Positives = 159/277 (57%), Gaps = 44/277 (16%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV++VL+GYDW+LVP+  + +G  K   HVKRPMNAFMVWAQAAR+ LADQYP LHN\n"+
"Sbjct  53   ISAAVTKVLQGYDWSLVPVATKGSGD-KRATHVKRPMNAFMVWAQAARKILADQYPQLHN  111\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA  192\n"+
"            AELSKTLGKLWR+L+++EK+PF+E+A+ LRV HK++HPDYKYQPRRRK       EA  +\n"+
"Sbjct  112  AELSKTLGKLWRVLSDTEKKPFIEQADLLRVIHKREHPDYKYQPRRRKQNGPSGREASPS  171\n"+
"\n"+
"Query  193  TEQTHISPNAIFKALQADS-----PHS-SSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQ  246\n"+
"              Q++++ N      Q D+     P+S  SG+S   SP     Q   P TPP TP+    \n"+
"Sbjct  172  RSQSNVTFNVSRSLKQEDASPRGGPNSPQSGVSS--SPPTTPNQGLCPLTPPATPRGQQH  229\n"+
"\n"+
"Query  247  PGKADL-KREGRPLP-------------------------EGGRQPPIDFRDVDIGE---  277\n"+
"                 + +R  +P                           E  +QP +DFR +++GE   \n"+
"Sbjct  230  YAANQVTERANQPAANQPAAQNSGNSTTVYQHEVAIGSSSESAQQPGVDFRYIEVGEGLP  289\n"+
"\n"+
"Query  278  ----LSSDVISNIETFDV--NEFDQYLPPNGHPGVPA  308\n"+
"                L  ++  N++  +V  NE DQYL P   P V A\n"+
"Sbjct  290  IEEGLGLNLPLNLQECEVESNELDQYLRPQMPPTVHA  326\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002109760.1<a name=XP_002109760></a> hypothetical protein TRIADDRAFT_21755 [Trichoplax adhaerens]\n"+
" EDV27926.1<a name=EDV27926></a> hypothetical protein TRIADDRAFT_21755, partial [Trichoplax adhaerens] \n"+
" \n"+
"Length=162\n"+
"\n"+
" Score = 174 bits (442),  Expect = 2e-49, Method: Compositional matrix adjust.\n"+
" Identities = 78/134 (58%), Positives = 106/134 (79%), Gaps = 0/134 (0%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            ++ AVS VL+ YDW+ VPM ++++ S +++ H+KRPMNAFMVWAQAAR+K+++QYP+LHN\n"+
"Sbjct  29   VKSAVSYVLQDYDWSSVPMSIKLHTSQRSRQHIKRPMNAFMVWAQAARQKISEQYPNLHN  88\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA  192\n"+
"            AELSKTLGKLW+LL + +K+PF+EEAERLR++HK DHPDYKYQPRR+   K   + +   \n"+
"Sbjct  89   AELSKTLGKLWKLLGDEQKQPFIEEAERLRIKHKMDHPDYKYQPRRKNKQKRAGSVSSGD  148\n"+
"\n"+
"Query  193  TEQTHISPNAIFKA  206\n"+
"             E   I  + IFKA\n"+
"Sbjct  149  DEPQEIPASEIFKA  162\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KOX79192.1<a name=KOX79192></a> Transcription factor Sox-10 [Melipona quadrifasciata]  \n"+
"Length=750\n"+
"\n"+
" Score = 188 bits (478),  Expect = 3e-49, Method: Compositional matrix adjust.\n"+
" Identities = 118/283 (42%), Positives = 153/283 (54%), Gaps = 58/283 (20%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV++VL+GYDWTLVP+  +   S K   HVKRPMNAFMVWAQAARR LADQYP LHN\n"+
"Sbjct  108  ISAAVTKVLQGYDWTLVPVATK-GSSDKRAAHVKRPMNAFMVWAQAARRILADQYPQLHN  166\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA  192\n"+
"            AELSKTLGKLWRLL++S+K+PF+EEA+RLRV HK++HPDYKYQPRRRK       E   +\n"+
"Sbjct  167  AELSKTLGKLWRLLSDSDKKPFIEEADRLRVIHKREHPDYKYQPRRRKQNGPSGREGSPS  226\n"+
"\n"+
"Query  193  TEQTHISPNAIFKALQAD-SPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKAD  251\n"+
"              Q++++ N      Q D SP  +         G +S QS    +PPTTP   + P    \n"+
"Sbjct  227  RNQSNVTFNVSRSLKQEDASPRGTQ--------GPNSPQSGVSSSPPTTPNQGLSPPTPP  278\n"+
"\n"+
"Query  252  LKREGRPLPEGGRQPP-------------------------IDFRDVDIGE---------  277\n"+
"                G+     G QP                          +DFR +++G+         \n"+
"Sbjct  279  TTPRGQHYANQGNQPQPNSTMYQQDLAIGSSSDSPHQHQPGVDFRYIEVGDGLSIEEGQL  338\n"+
"\n"+
"Query  278  --------LSSDVISNIETFDV--NEFDQYLPPNGHPGVPATH  310\n"+
"                    +  ++  N++  +V  NE DQYL     P VP+ H\n"+
"Sbjct  339  NGLGSLAGVGLNLPLNLQECEVENNELDQYL----RPQVPSVH  377\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAK69337.1<a name=BAK69337></a> SoxE protein, partial [Balanoglossus simodensis]  \n"+
"Length=179\n"+
"\n"+
" Score = 174 bits (440),  Expect = 6e-49, Method: Compositional matrix adjust.\n"+
" Identities = 108/185 (58%), Positives = 129/185 (70%), Gaps = 16/185 (9%)\n"+
"\n"+
"Query  116  AQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQ  175\n"+
"            AQAAR+KLADQYPHLHNAELSKTLGKLWR+L++ EK+PFV+EAERLR+QHKKDHPDYKYQ\n"+
"Sbjct  1    AQAARKKLADQYPHLHNAELSKTLGKLWRMLSDKEKKPFVDEAERLRLQHKKDHPDYKYQ  60\n"+
"\n"+
"Query  176  PRRRKSVKNGQAEAEEATEQTHI-SPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGP  234\n"+
"            PRRRK++KNGQ  +++ T  +    P    K LQ D P         ++ G   G + GP\n"+
"Sbjct  61   PRRRKAMKNGQQNSQDETGSSSSPVPINFCKVLQRDRPPGKGD----NNTGGSGGTAHGP  116\n"+
"\n"+
"Query  235  PTPPTTPKTDVQPGKADLKREGRPL--------PEGGRQPPIDFRDVDIGELSSDVISNI  286\n"+
"            PTPPTTPKT+     A+  REG PL        P G + P IDF  VDI ELS++VISNI\n"+
"Sbjct  117  PTPPTTPKTESASTPAE--REG-PLTKKMKLVRPGGDQDPQIDFNGVDIRELSTEVISNI  173\n"+
"\n"+
"Query  287  ETFDV  291\n"+
"            E FDV\n"+
"Sbjct  174  EGFDV  178\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AHG06472.1<a name=AHG06472></a> SRY-box containing protein 9, partial [Lates calcarifer]  \n"+
"Length=93\n"+
"\n"+
" Score = 171 bits (432),  Expect = 6e-49, Method: Compositional matrix adjust.\n"+
" Identities = 80/94 (85%), Positives = 87/94 (93%), Gaps = 1/94 (1%)\n"+
"\n"+
"Query  25   TMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVLKGY  84\n"+
"            +MSEDSAGSPCPSGSGSDTENTRP +N   +G+ D KKE EE+KFPVCIR+AVSQVLKGY\n"+
"Sbjct  1    SMSEDSAGSPCPSGSGSDTENTRPSDNHLLRGQ-DYKKEGEEEKFPVCIRDAVSQVLKGY  59\n"+
"\n"+
"Query  85   DWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQA  118\n"+
"            DWTLVPMPVRVNGSSK+KPHVKRPMNAFMVWAQA\n"+
"Sbjct  60   DWTLVPMPVRVNGSSKSKPHVKRPMNAFMVWAQA  93\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">CBY02482.1<a name=CBY02482></a> putative SRY (sex determining region Y)-box 9, partial [Talpa \n"+
"occidentalis]  \n"+
"Length=81\n"+
"\n"+
" Score = 170 bits (430),  Expect = 7e-49, Method: Compositional matrix adjust.\n"+
" Identities = 81/81 (100%), Positives = 81/81 (100%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  15  EKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIR  74\n"+
"           EKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIR\n"+
"Sbjct  1   EKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIR  60\n"+
"\n"+
"Query  75  EAVSQVLKGYDWTLVPMPVRV  95\n"+
"           EAVSQVLKGYDWTLVPMPVRV\n"+
"Sbjct  61  EAVSQVLKGYDWTLVPMPVRV  81\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ABN50067.1<a name=ABN50067></a> SRY-box containing 9, partial [Capra hircus]  \n"+
"Length=251\n"+
"\n"+
" Score = 176 bits (446),  Expect = 7e-49, Method: Compositional matrix adjust.\n"+
" Identities = 83/85 (98%), Positives = 85/85 (100%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  238  PTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQY  297\n"+
"            PTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISN+ETFDV+EFDQY\n"+
"Sbjct  1    PTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNMETFDVHEFDQY  60\n"+
"\n"+
"Query  298  LPPNGHPGVPATHGQVTYTGSYGIS  322\n"+
"            LPPNGHPGVPATHGQVTYTGSYGIS\n"+
"Sbjct  61   LPPNGHPGVPATHGQVTYTGSYGIS  85\n"+
"\n"+
"\n"+
" Score = 120 bits (302),  Expect = 3e-28, Method: Compositional matrix adjust.\n"+
" Identities = 56/66 (85%), Positives = 63/66 (95%), Gaps = 0/66 (0%)\n"+
"\n"+
"Query  423  FNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIAD  482\n"+
"            F+LPHY PSYPPITR+QYDY+D QNS +YYSHAAGQG+GLYSTF+YM+PAQRPMYTPIAD\n"+
"Sbjct  186  FSLPHYGPSYPPITRAQYDYSDPQNSGAYYSHAAGQGSGLYSTFSYMSPAQRPMYTPIAD  245\n"+
"\n"+
"Query  483  TSGVPS  488\n"+
"            TSGVPS\n"+
"Sbjct  246  TSGVPS  251\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAR73294.1<a name=BAR73294></a> Sox9 [Peronella japonica]  \n"+
"Length=525\n"+
"\n"+
" Score = 182 bits (463),  Expect = 1e-48, Method: Compositional matrix adjust.\n"+
" Identities = 80/109 (73%), Positives = 94/109 (86%), Gaps = 0/109 (0%)\n"+
"\n"+
"Query  68   KFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQY  127\n"+
"            +F   IR+AVS+VL GYDW++V +P R   S K KPH+KRPMNAFMVWAQAAR+KL +QY\n"+
"Sbjct  76   QFSPSIRDAVSRVLNGYDWSVVAVPTRTGSSGKRKPHIKRPMNAFMVWAQAARKKLGNQY  135\n"+
"\n"+
"Query  128  PHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQP  176\n"+
"            P LHNAELSKTLGKLWRLL++ EK+PF+EEAERLR QHKKD+PDYKYQP\n"+
"Sbjct  136  PQLHNAELSKTLGKLWRLLSDKEKQPFIEEAERLRQQHKKDYPDYKYQP  184\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_016402817.1<a name=XP_016402817></a> PREDICTED: transcription factor Sox-8-like, partial [Sinocyclocheilus \n"+
"rhinocerous]  \n"+
"Length=132\n"+
"\n"+
" Score = 169 bits (429),  Expect = 4e-48, Method: Compositional matrix adjust.\n"+
" Identities = 86/136 (63%), Positives = 103/136 (76%), Gaps = 6/136 (4%)\n"+
"\n"+
"Query  10   MTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQE--NTFPKGEPDLKKESEED  67\n"+
"            MT+EQE+  +  P P      AGS C S S  ++++  P     +  +    L  + E++\n"+
"Sbjct  1    MTEEQERSSAEPPPPC---SPAGS-CSSLSAEESDSDAPSSPAGSASRAALILPGKDEDE  56\n"+
"\n"+
"Query  68   KFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQY  127\n"+
"            +FP CIR+AVSQVLKGYDW+LVPMPVRVNGSS++KPHVKRPMNAFMVWAQAARRKLADQY\n"+
"Sbjct  57   RFPACIRDAVSQVLKGYDWSLVPMPVRVNGSSRSKPHVKRPMNAFMVWAQAARRKLADQY  116\n"+
"\n"+
"Query  128  PHLHNAELSKTLGKLW  143\n"+
"            PHLHNAELSKTLGKLW\n"+
"Sbjct  117  PHLHNAELSKTLGKLW  132\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACU12311.1<a name=ACU12311></a> Sox9 isoform 15, partial [Mus musculus]  \n"+
"Length=124\n"+
"\n"+
" Score = 169 bits (428),  Expect = 5e-48, Method: Compositional matrix adjust.\n"+
" Identities = 82/87 (94%), Positives = 84/87 (97%), Gaps = 0/87 (0%)\n"+
"\n"+
"Query  383  TTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDY  442\n"+
"             TLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQI+YSPFNLPHYSPSYPPITRSQYDY\n"+
"Sbjct  38   NTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQISYSPFNLPHYSPSYPPITRSQYDY  97\n"+
"\n"+
"Query  443  TDHQNSSSYYSHAAGQGTGLYSTFTYM  469\n"+
"             DHQNS SYYSHAAGQG+GLYSTFTYM\n"+
"Sbjct  98   ADHQNSGSYYSHAAGQGSGLYSTFTYM  124\n"+
"\n"+
"\n"+
" Score = 80.9 bits (198),  Expect = 2e-15, Method: Compositional matrix adjust.\n"+
" Identities = 36/38 (95%), Positives = 36/38 (95%), Gaps = 0/38 (0%)\n"+
"\n"+
"Query  248  GKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISN  285\n"+
"            GK DLKREGRPL EGGRQPPIDFRDVDIGELSSDVISN\n"+
"Sbjct  1    GKVDLKREGRPLAEGGRQPPIDFRDVDIGELSSDVISN  38\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013863558.1<a name=XP_013863558></a> PREDICTED: transcription factor Sox-9-A-like, partial [Austrofundulus \n"+
"limnaeus]  \n"+
"Length=207\n"+
"\n"+
" Score = 172 bits (435),  Expect = 7e-48, Method: Compositional matrix adjust.\n"+
" Identities = 123/242 (51%), Positives = 145/242 (60%), Gaps = 49/242 (20%)\n"+
"\n"+
"Query  282  VISNIETFDVNEFDQYLPPNGHPGVPATHGQ---VTYTGSYGISSTA--ATPASAGHVWM  336\n"+
"            VIS+IETFDVNEFDQYLPPNGHP +P+  G    ++YTGSY IS  A  +     G  W \n"+
"Sbjct  1    VISHIETFDVNEFDQYLPPNGHPALPSGPGSATPISYTGSYSISCGAPLSPQEGGGSAWG  60\n"+
"\n"+
"Query  337  SKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTH  396\n"+
"            +K Q      QQ P AP                               +   P    RT \n"+
"Sbjct  61   AKSQT-----QQGPLAPLG--------------------------AAGVLEAPQNQHRTQ  89\n"+
"\n"+
"Query  397  IKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSP--SYPPITRSQ-YDYTDHQ---NSSS  450\n"+
"            IKTEQLSP+HYS+ Q  SPQ   YSPF+L HYSP  SYP I R+Q Y+Y+DHQ   N+ S\n"+
"Sbjct  90   IKTEQLSPTHYSDPQG-SPQH--YSPFSLQHYSPPSSYPAICRAQPYNYSDHQGGTNAPS  146\n"+
"\n"+
"Query  451  YYSHA-AGQGTGLYSTFTYM-NPAQRPMYTPIADTSGVPSIPQTHSPQHWEQ-PVYTQLT  507\n"+
"            YYSHA A QG+ L+ST++YM +P  R MYTP AD+ G P IPQ +SPQHWEQ PVYTQLT\n"+
"Sbjct  147  YYSHAGASQGSSLFSTYSYMSSPTHRSMYTPTADSPGGPPIPQ-NSPQHWEQAPVYTQLT  205\n"+
"\n"+
"Query  508  RP  509\n"+
"            RP\n"+
"Sbjct  206  RP  207\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011302474.1<a name=XP_011302474></a> PREDICTED: transcription factor Sox-10-like [Fopius arisanus] \n"+
" \n"+
"Length=423\n"+
"\n"+
" Score = 178 bits (451),  Expect = 9e-48, Method: Compositional matrix adjust.\n"+
" Identities = 96/174 (55%), Positives = 121/174 (70%), Gaps = 16/174 (9%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV++VL+GY+WTLVP+  +  G+ K   HVKRPMNAFMVWAQAARRKLADQYP LHN\n"+
"Sbjct  51   ISAAVAKVLQGYNWTLVPVATK--GTDKRTAHVKRPMNAFMVWAQAARRKLADQYPQLHN  108\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEE-  191\n"+
"            AELSKTLG LWR L++ +K+PF+EEA+RLRV HK++HPDYKYQPRRRK  +NG +   E \n"+
"Sbjct  109  AELSKTLGTLWRKLSDDDKKPFIEEADRLRVIHKREHPDYKYQPRRRK--QNGASSGLEN  166\n"+
"\n"+
"Query  192  --ATEQTHISPNAIFKALQAD-SPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPK  242\n"+
"                 Q++++ N      Q D SP  + G +        S QS+   +PPTTP \n"+
"Sbjct  167  PPVRNQSNVAFNVSNSLKQEDLSPRGNQGPA--------SPQSRVSSSPPTTPN  212\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_003245920.1<a name=XP_003245920></a> PREDICTED: transcription factor Sox-10 [Acyrthosiphon pisum] \n"+
" \n"+
"Length=346\n"+
"\n"+
" Score = 174 bits (442),  Expect = 3e-47, Method: Compositional matrix adjust.\n"+
" Identities = 82/111 (74%), Positives = 94/111 (85%), Gaps = 1/111 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I +AVS+VL GYDWTLVP+P +     KN  HVKRPMNAFMVWAQAARRKLADQYP LHN\n"+
"Sbjct  45   INDAVSKVLGGYDWTLVPVPAKPPTEKKNY-HVKRPMNAFMVWAQAARRKLADQYPQLHN  103\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            AELSKTLG+LWRLL+  +K+PF+EEAE+LRV HK  +PDYKYQPRRRK+ K\n"+
"Sbjct  104  AELSKTLGQLWRLLSGDDKQPFIEEAEKLRVLHKNRYPDYKYQPRRRKAAK  154\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_008213434.1<a name=XP_008213434></a> PREDICTED: transcription factor SOX-9-like [Nasonia vitripennis]\n"+
" XP_008213435.1<a name=XP_008213435></a> PREDICTED: transcription factor SOX-9-like [Nasonia vitripennis]\n"+
" XP_008213438.1<a name=XP_008213438></a> PREDICTED: transcription factor SOX-9-like [Nasonia vitripennis]\n"+
" XP_008213439.1<a name=XP_008213439></a> PREDICTED: transcription factor SOX-9-like [Nasonia vitripennis]\n"+
" XP_016839540.1<a name=XP_016839540></a> PREDICTED: transcription factor SOX-9-like [Nasonia vitripennis] \n"+
" \n"+
"Length=358\n"+
"\n"+
" Score = 174 bits (442),  Expect = 4e-47, Method: Compositional matrix adjust.\n"+
" Identities = 79/121 (65%), Positives = 97/121 (80%), Gaps = 2/121 (2%)\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            K ++   + P  + +AV ++L+GYDWTL+P+  R  G  +   HVKRPMNAFMVWAQAAR\n"+
"Sbjct  30   KAKAATVREPSSLDDAVGKLLQGYDWTLLPVTSRAGG--RRSAHVKRPMNAFMVWAQAAR  87\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            R+LADQYP LHNAELSKTLGKLWR+L++ EK+PF+EEAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  88   RRLADQYPQLHNAELSKTLGKLWRILSDGEKQPFIEEAERLRSAHKKQHPHYKYQPRRRK  147\n"+
"\n"+
"Query  181  S  181\n"+
"            +\n"+
"Sbjct  148  A  148\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AHG56859.1<a name=AHG56859></a> sox9b, partial [Clarias batrachus]  \n"+
"Length=186\n"+
"\n"+
" Score = 168 bits (426),  Expect = 7e-47, Method: Compositional matrix adjust.\n"+
" Identities = 119/255 (47%), Positives = 142/255 (56%), Gaps = 85/255 (33%)\n"+
"\n"+
"Query  262  GGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGI  321\n"+
"            G RQ  IDFRDVD+GELSSDVIS++E+FDV EFDQYLPPNGHPG    HG +        \n"+
"Sbjct  8    GQRQLNIDFRDVDLGELSSDVISHMESFDVAEFDQYLPPNGHPG----HGWM--------  55\n"+
"\n"+
"Query  322  SSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHT  381\n"+
"                   +SAG  WM+K                +P + PQ  A  P +            \n"+
"Sbjct  56   -------SSAGSGWMTK----------------SPSSSPQVGATSPGE------------  80\n"+
"\n"+
"Query  382  LTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPS-----YPP-I  435\n"+
"                  +  Q + THIKTEQLSPSHY               FNL HY+ S     +P  I\n"+
"Sbjct  81   ------DQSQQRTTHIKTEQLSPSHYGS-------------FNLQHYTTSTSSSAFPSCI  121\n"+
"\n"+
"Query  436  TRSQYDYTDHQ-NSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADT-SGVPSIPQTH  493\n"+
"            +R QYDYT+ Q  S+SYYS  AGQG+ LYSTF YM+P+QRPMYTPI +T SG       H\n"+
"Sbjct  122  SRPQYDYTEQQAGSASYYS--AGQGS-LYSTFNYMSPSQRPMYTPITETQSG-------H  171\n"+
"\n"+
"Query  494  SPQHWE-QPVYTQLT  507\n"+
"            SPQHW+ QPVYTQL+\n"+
"Sbjct  172  SPQHWDQQPVYTQLS  186\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011494181.1<a name=XP_011494181></a> PREDICTED: transcription factor Sox-21-B [Ceratosolen solmsi \n"+
"marchali]  \n"+
"Length=323\n"+
"\n"+
" Score = 172 bits (437),  Expect = 1e-46, Method: Compositional matrix adjust.\n"+
" Identities = 77/108 (71%), Positives = 91/108 (84%), Gaps = 2/108 (2%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            + +AV ++L+GYDWTL+P+  R  G  +   HVKRPMNAFMVWAQAARR+LADQYP LHN\n"+
"Sbjct  37   LDDAVGKLLQGYDWTLLPVTSRAGG--RRSAHVKRPMNAFMVWAQAARRRLADQYPQLHN  94\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AELSKTLGKLWR+L++ EK+PF+EEAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  95   AELSKTLGKLWRILSDGEKQPFIEEAERLRSAHKKQHPHYKYQPRRRK  142\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_003702900.1<a name=XP_003702900></a> PREDICTED: transcription factor Sox-8-like [Megachile rotundata] \n"+
" \n"+
"Length=335\n"+
"\n"+
" Score = 172 bits (436),  Expect = 2e-46, Method: Compositional matrix adjust.\n"+
" Identities = 77/108 (71%), Positives = 91/108 (84%), Gaps = 2/108 (2%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            + +AV ++L+GYDWTL+P+  R  G  +   HVKRPMNAFMVWAQAARR+LADQYP LHN\n"+
"Sbjct  28   LEDAVGKLLQGYDWTLLPVTSRAGG--RRSAHVKRPMNAFMVWAQAARRRLADQYPQLHN  85\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AELSKTLGKLWR+L++ EK+PF+EEAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  86   AELSKTLGKLWRILSDGEKQPFIEEAERLRNAHKKQHPHYKYQPRRRK  133\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015588627.1<a name=XP_015588627></a> PREDICTED: transcription factor Sox-10-like [Cephus cinctus] \n"+
" \n"+
"Length=318\n"+
"\n"+
" Score = 172 bits (435),  Expect = 2e-46, Method: Compositional matrix adjust.\n"+
" Identities = 77/108 (71%), Positives = 91/108 (84%), Gaps = 2/108 (2%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            + +AV ++L+GYDWTL+P+  R  G  +   HVKRPMNAFMVWAQAARR+LADQYP LHN\n"+
"Sbjct  25   LDDAVGKLLQGYDWTLLPVTSRAGG--RRSAHVKRPMNAFMVWAQAARRRLADQYPQLHN  82\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AELSKTLGKLWR+L++ EK+PF+EEAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  83   AELSKTLGKLWRILSDGEKQPFIEEAERLRNAHKKQHPHYKYQPRRRK  130\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014931793.1<a name=XP_014931793></a> PREDICTED: transcription factor SOX-9, partial [Acinonyx jubatus] \n"+
" \n"+
"Length=181\n"+
"\n"+
" Score = 167 bits (423),  Expect = 2e-46, Method: Compositional matrix adjust.\n"+
" Identities = 87/118 (74%), Positives = 91/118 (77%), Gaps = 25/118 (21%)\n"+
"\n"+
"Query  392  SQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSY  451\n"+
"            ++RTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPS+P                  \n"+
"Sbjct  89   ARRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSHP------------------  130\n"+
"\n"+
"Query  452  YSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"                   G  LYSTF+YMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  131  -------GPSLYSTFSYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  181\n"+
"\n"+
"\n"+
" Score = 120 bits (302),  Expect = 4e-29, Method: Compositional matrix adjust.\n"+
" Identities = 65/74 (88%), Positives = 67/74 (91%), Gaps = 3/74 (4%)\n"+
"\n"+
"Query  169  HPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSP-GEH  227\n"+
"            HPDYK+QPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSP GEH\n"+
"Sbjct  2    HPDYKHQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGGEH  61\n"+
"\n"+
"Query  228  SGQSQGPPTPPTTP  241\n"+
"            SG+S     PP TP\n"+
"Sbjct  62   SGESSH--KPPATP  73\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017767188.1<a name=XP_017767188></a> PREDICTED: transcription factor Sox-10-like isoform X1 [Eufriesea \n"+
"mexicana]  \n"+
"Length=448\n"+
"\n"+
" Score = 174 bits (442),  Expect = 3e-46, Method: Compositional matrix adjust.\n"+
" Identities = 97/170 (57%), Positives = 119/170 (70%), Gaps = 10/170 (6%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKP-HVKRPMNAFMVWAQAARRKLADQYPHLH  131\n"+
"            I  AV++VL+GYDWTL P  V   GS   +P HVKRPMNAFMVWAQAARR LADQYP  H\n"+
"Sbjct  70   ISAAVTKVLRGYDWTLDP--VVTKGSGDKRPAHVKRPMNAFMVWAQAARRILADQYPQRH  127\n"+
"\n"+
"Query  132  NAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEE  191\n"+
"            NAELSKTLGKLWRLL++++K+PF+EEA+RLRV HK++HPDYKYQPRRRK  +NG +   E\n"+
"Sbjct  128  NAELSKTLGKLWRLLSDNDKKPFIEEADRLRVIHKREHPDYKYQPRRRK--QNGPS-GRE  184\n"+
"\n"+
"Query  192  ATEQTHISPNAIFKALQADSPHSSS--GMSEVHSPGEHSGQSQGPPTPPT  239\n"+
"             +   + S N  F   ++     +S  G+   +SP   SG S  PPT P \n"+
"Sbjct  185  GSPSRNQSNNVTFNVSRSLKQEDASPRGVQGPNSP--QSGTSSSPPTTPN  232\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010408412.1<a name=XP_010408412></a> PREDICTED: transcription factor SOX-9 [Corvus cornix cornix] \n"+
" \n"+
"Length=170\n"+
"\n"+
" Score = 166 bits (420),  Expect = 3e-46, Method: Compositional matrix adjust.\n"+
" Identities = 88/94 (94%), Positives = 90/94 (96%), Gaps = 0/94 (0%)\n"+
"\n"+
"Query  144  RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAI  203\n"+
"            RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAE EE +EQTHISPNAI\n"+
"Sbjct  21   RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEQEEGSEQTHISPNAI  80\n"+
"\n"+
"Query  204  FKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTP  237\n"+
"            FKALQADSP SSS +SEVHSPGEHSGQSQGPPTP\n"+
"Sbjct  81   FKALQADSPQSSSSISEVHSPGEHSGQSQGPPTP  114\n"+
"\n"+
"\n"+
" Score = 117 bits (294),  Expect = 4e-28, Method: Compositional matrix adjust.\n"+
" Identities = 53/56 (95%), Positives = 56/56 (100%), Gaps = 0/56 (0%)\n"+
"\n"+
"Query  454  HAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            HAAGQG+GLYSTF+YMNP+QRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP\n"+
"Sbjct  115  HAAGQGSGLYSTFSYMNPSQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  170\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012271640.1<a name=XP_012271640></a> PREDICTED: transcription factor SOX-10-like [Orussus abietinus] \n"+
" \n"+
"Length=289\n"+
"\n"+
" Score = 170 bits (430),  Expect = 4e-46, Method: Compositional matrix adjust.\n"+
" Identities = 78/108 (72%), Positives = 91/108 (84%), Gaps = 2/108 (2%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            + +AV ++L+GYDWTL+P+  R  G  +   HVKRPMNAFMVWAQAARR+LADQYP LHN\n"+
"Sbjct  24   LDDAVGKLLQGYDWTLLPVTSRAGG--RRSAHVKRPMNAFMVWAQAARRRLADQYPQLHN  81\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AELSKTLGKLWR+L++ EK+PFVEEAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  82   AELSKTLGKLWRILSDGEKQPFVEEAERLRSAHKKQHPHYKYQPRRRK  129\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_008559241.1<a name=XP_008559241></a> PREDICTED: sex-determining region Y protein [Microplitis demolitor] \n"+
" \n"+
"Length=321\n"+
"\n"+
" Score = 171 bits (432),  Expect = 5e-46, Method: Compositional matrix adjust.\n"+
" Identities = 78/108 (72%), Positives = 91/108 (84%), Gaps = 2/108 (2%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            + +AV ++L+GYDWTL+P+  R  G  +   HVKRPMNAFMVWAQAARRKLADQYP LHN\n"+
"Sbjct  23   LDDAVGKLLQGYDWTLLPVTSRTGG--RRSTHVKRPMNAFMVWAQAARRKLADQYPQLHN  80\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AELSKTLGKLWR+L++ EK+PF+EEAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  81   AELSKTLGKLWRILSDGEKQPFIEEAERLRNAHKKQHPHYKYQPRRRK  128\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014228418.1<a name=XP_014228418></a> PREDICTED: transcription factor SOX-8-like, partial [Trichogramma \n"+
"pretiosum]  \n"+
"Length=198\n"+
"\n"+
" Score = 166 bits (421),  Expect = 6e-46, Method: Compositional matrix adjust.\n"+
" Identities = 76/111 (68%), Positives = 93/111 (84%), Gaps = 3/111 (3%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVR--VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHL  130\n"+
"            + +AV ++L+GYDWTL+P+  R   +GS +   H+KRPMNAFMVWAQAARR+LA QYP L\n"+
"Sbjct  49   LDDAVGKLLEGYDWTLLPVTSRTCCDGSGR-ASHIKRPMNAFMVWAQAARRRLAVQYPQL  107\n"+
"\n"+
"Query  131  HNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS  181\n"+
"            HNAELSKTLGKLWR+L++ EK+PF+EEAERLR  HKK HP YKYQPRRRK+\n"+
"Sbjct  108  HNAELSKTLGKLWRILSDGEKKPFIEEAERLRNAHKKQHPHYKYQPRRRKA  158\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_008470663.1<a name=XP_008470663></a> PREDICTED: transcription factor Sox-10 [Diaphorina citri]  \n"+
"Length=382\n"+
"\n"+
" Score = 172 bits (435),  Expect = 8e-46, Method: Compositional matrix adjust.\n"+
" Identities = 114/265 (43%), Positives = 146/265 (55%), Gaps = 37/265 (14%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I+EAVS+VL+GYDWTLVP   +     +   HVKRPMNAFMVWAQAARR LA+QYP LHN\n"+
"Sbjct  42   IKEAVSKVLQGYDWTLVPTATKTTTEKRKT-HVKRPMNAFMVWAQAARRTLANQYPSLHN  100\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA  192\n"+
"            AELSKTLG LW+ L++S+K+PF+EEAERLR  HK +HP+YKYQPRRRK  KN    A   \n"+
"Sbjct  101  AELSKTLGVLWKKLSDSDKKPFIEEAERLRQIHKSEHPNYKYQPRRRKCSKNLGTSANNL  160\n"+
"\n"+
"Query  193  TEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADL  252\n"+
"            ++ T    ++I    Q D   S+   S  +SP +       P TPP TP   +   +   \n"+
"Sbjct  161  SKST----SSINSLKQEDYSSSADEGSSSYSPSQ-------PLTPPGTPNKRLATTRFQP  209\n"+
"\n"+
"Query  253  KREGRPLPEGGRQPP-----------------IDFRDVDIGELSSDVISNIETFDVNEF-  294\n"+
"                  L +     P                  DF +  I +L + V ++  T D +E  \n"+
"Sbjct  210  SLSSSSLDQLPSTSPHPTSAPHSTSATDSLHYADFIN-RIDDL-TPVTNDDSTLDSSELV  267\n"+
"\n"+
"Query  295  DQYLPPNGHPGVPATHGQVTYTGSY  319\n"+
"            DQYLP  G     AT G   ++G Y\n"+
"Sbjct  268  DQYLPSYG-----ATSGGCLHSGVY  287\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011347627.1<a name=XP_011347627></a> PREDICTED: transcription factor Sox-1a-like [Cerapachys biroi] \n"+
" \n"+
"Length=399\n"+
"\n"+
" Score = 172 bits (435),  Expect = 1e-45, Method: Compositional matrix adjust.\n"+
" Identities = 77/108 (71%), Positives = 91/108 (84%), Gaps = 2/108 (2%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            + +AV ++L+GYDWTL+P+  R  G  +   HVKRPMNAFMVWAQAARR+LADQYP LHN\n"+
"Sbjct  76   LDDAVGKLLQGYDWTLLPVTSRAGG--RRSAHVKRPMNAFMVWAQAARRRLADQYPQLHN  133\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AELSKTLGKLWR+L++ EK+PF+EEAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  134  AELSKTLGKLWRILSDGEKQPFIEEAERLRNAHKKQHPHYKYQPRRRK  181\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012262253.1<a name=XP_012262253></a> PREDICTED: transcription factor Sox-8-like [Athalia rosae]  \n"+
"Length=383\n"+
"\n"+
" Score = 171 bits (434),  Expect = 1e-45, Method: Compositional matrix adjust.\n"+
" Identities = 76/108 (70%), Positives = 92/108 (85%), Gaps = 2/108 (2%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            + +AV ++L+GYDWTL+P+  R  G  +   HVKRPMNAFMVWAQAARR+LADQYP LHN\n"+
"Sbjct  24   LDDAVGKLLQGYDWTLLPVTSRAGG--RRSAHVKRPMNAFMVWAQAARRRLADQYPQLHN  81\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AELSKTLGKLWR+L+++EK+PF+EEAERLR  HKK HP YKYQPRRR+\n"+
"Sbjct  82   AELSKTLGKLWRILSDAEKQPFIEEAERLRNAHKKQHPHYKYQPRRRR  129\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014211338.1<a name=XP_014211338></a> PREDICTED: sex-determining region Y protein-like [Copidosoma \n"+
"floridanum]  \n"+
"Length=364\n"+
"\n"+
" Score = 171 bits (432),  Expect = 1e-45, Method: Compositional matrix adjust.\n"+
" Identities = 77/111 (69%), Positives = 94/111 (85%), Gaps = 2/111 (2%)\n"+
"\n"+
"Query  70   PVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPH  129\n"+
"            P  + +AV ++L+GYDWTL+P+  R +G  +   HVKRPMNAFMVWAQAARRKLADQ+P \n"+
"Sbjct  22   PNSLDDAVGKLLQGYDWTLLPVTARASG--RRSAHVKRPMNAFMVWAQAARRKLADQHPQ  79\n"+
"\n"+
"Query  130  LHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            LHNAELSKTLGKLWR+L+++EK+PF++EAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  80   LHNAELSKTLGKLWRILSDAEKQPFIDEAERLRSAHKKQHPHYKYQPRRRK  130\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011302468.1<a name=XP_011302468></a> PREDICTED: transcription factor Sox-17-alpha-B-like isoform X1 \n"+
"[Fopius arisanus]  \n"+
"Length=328\n"+
"\n"+
" Score = 169 bits (427),  Expect = 3e-45, Method: Compositional matrix adjust.\n"+
" Identities = 76/108 (70%), Positives = 90/108 (83%), Gaps = 2/108 (2%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            + +AV ++L+GY+WTL+P+  R  G  +   HVKRPMNAFMVWAQAARR+LADQYP LHN\n"+
"Sbjct  27   LDDAVGKLLQGYNWTLLPITSR--GGGRRSTHVKRPMNAFMVWAQAARRRLADQYPQLHN  84\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AELSKTLGKLWR+L + EK+PF+EEAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  85   AELSKTLGKLWRILTDGEKQPFIEEAERLRNAHKKQHPHYKYQPRRRK  132\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KKF09025.1<a name=KKF09025></a> Transcription factor SOX-10 [Larimichthys crocea]  \n"+
"Length=187\n"+
"\n"+
" Score = 164 bits (414),  Expect = 4e-45, Method: Compositional matrix adjust.\n"+
" Identities = 74/84 (88%), Positives = 77/84 (92%), Gaps = 0/84 (0%)\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            K E EED+FP+ IREAVSQVL GYDWTLVPMPVRVN  +K KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  65   KSEEEEDRFPIGIREAVSQVLDGYDWTLVPMPVRVNNGNKAKPHVKRPMNAFMVWAQAAR  124\n"+
"\n"+
"Query  121  RKLADQYPHLHNAELSKTLGKLWR  144\n"+
"            RKLADQYPHLHNAELSKTLGKLWR\n"+
"Sbjct  125  RKLADQYPHLHNAELSKTLGKLWR  148\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_008559245.1<a name=XP_008559245></a> PREDICTED: transcription factor Sox-8 [Microplitis demolitor] \n"+
" \n"+
"Length=457\n"+
"\n"+
" Score = 172 bits (435),  Expect = 4e-45, Method: Compositional matrix adjust.\n"+
" Identities = 79/108 (73%), Positives = 91/108 (84%), Gaps = 1/108 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            + EAV++VL GYDWTLVP+  +   S K   HVKRPMNAFMVWAQAAR+KLA Q+P LHN\n"+
"Sbjct  61   LSEAVAKVLDGYDWTLVPVATK-GTSDKRTAHVKRPMNAFMVWAQAARKKLAKQHPQLHN  119\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AELSKTLGKLWRLL E EK+PF+E A+RLRV HK++HPDYKYQPRRRK\n"+
"Sbjct  120  AELSKTLGKLWRLLKEVEKKPFIEAADRLRVIHKREHPDYKYQPRRRK  167\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EZA48830.1<a name=EZA48830></a> Transcription factor Sox-9-B [Cerapachys biroi]  \n"+
"Length=329\n"+
"\n"+
" Score = 168 bits (425),  Expect = 6e-45, Method: Compositional matrix adjust.\n"+
" Identities = 76/110 (69%), Positives = 88/110 (80%), Gaps = 2/110 (2%)\n"+
"\n"+
"Query  71   VCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHL  130\n"+
"            + I  + + V  GYDWTL+P+  R  G  +   HVKRPMNAFMVWAQAARR+LADQYP L\n"+
"Sbjct  4    IKITNSSTVVFAGYDWTLLPVTSRAGG--RRSAHVKRPMNAFMVWAQAARRRLADQYPQL  61\n"+
"\n"+
"Query  131  HNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            HNAELSKTLGKLWR+L++ EK+PF+EEAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  62   HNAELSKTLGKLWRILSDGEKQPFIEEAERLRNAHKKQHPHYKYQPRRRK  111\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015800813.1<a name=XP_015800813></a> PREDICTED: transcription factor SOX-10-like, partial [Nothobranchius \n"+
"furzeri]  \n"+
"Length=337\n"+
"\n"+
" Score = 167 bits (423),  Expect = 1e-44, Method: Compositional matrix adjust.\n"+
" Identities = 96/177 (54%), Positives = 111/177 (63%), Gaps = 16/177 (9%)\n"+
"\n"+
"Query  128  PHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQA  187\n"+
"            P LHNAELSKTLGKLWRLLNE EKRPFVEEAERLRVQHKKDHPDYKYQPRRRK+ K G +\n"+
"Sbjct  2    PDLHNAELSKTLGKLWRLLNEGEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKNGKPGSS  61\n"+
"\n"+
"Query  188  EAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQP  247\n"+
"               EA        ++             SG +     GE  G+ +G         T    \n"+
"Sbjct  62   SGSEADGHLEGESHSPPTPPTTPKTEPLSGKA-----GE--GKREG---------TGNVG  105\n"+
"\n"+
"Query  248  GKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHP  304\n"+
"             +  L  EG   P G  +P IDF +VDIGE+S +V++N+E FDVNEFDQYLPPNGHP\n"+
"Sbjct  106  SRGTLGAEGGSGPPGSGKPHIDFGNVDIGEISHEVMANMEPFDVNEFDQYLPPNGHP  162\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACU12306.1<a name=ACU12306></a> Sox9 isoform 10, partial [Mus musculus]  \n"+
"Length=110\n"+
"\n"+
" Score = 159 bits (403),  Expect = 2e-44, Method: Compositional matrix adjust.\n"+
" Identities = 74/76 (97%), Positives = 74/76 (97%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  248  GKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP  307\n"+
"            GK DLKREGRPL EGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP\n"+
"Sbjct  1    GKVDLKREGRPLAEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP  60\n"+
"\n"+
"Query  308  ATHGQVTYTGSYGISS  323\n"+
"            ATHGQVTYTGSYGISS\n"+
"Sbjct  61   ATHGQVTYTGSYGISS  76\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_001604913.2<a name=XP_001604913></a> PREDICTED: transcription factor Sox-9-B isoform X1 [Nasonia vitripennis] \n"+
" \n"+
"Length=476\n"+
"\n"+
" Score = 170 bits (431),  Expect = 2e-44, Method: Compositional matrix adjust.\n"+
" Identities = 77/108 (71%), Positives = 92/108 (85%), Gaps = 1/108 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV++VL+GYDWTLVP+  +   + K   HVKRPMNAFMVWAQAAR++LADQYP LHN\n"+
"Sbjct  53   ISAAVAKVLQGYDWTLVPVASK-GSNDKRVAHVKRPMNAFMVWAQAARKRLADQYPQLHN  111\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AELSKTLG LWR L+ES+K+PF+EEA+RLRV HK+ HPDYKYQPRR+K\n"+
"Sbjct  112  AELSKTLGSLWRQLSESDKKPFIEEADRLRVIHKRTHPDYKYQPRRKK  159\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_003741216.1<a name=XP_003741216></a> PREDICTED: transcription factor Sox-9-A-like [Metaseiulus occidentalis] \n"+
" \n"+
"Length=233\n"+
"\n"+
" Score = 163 bits (412),  Expect = 3e-44, Method: Compositional matrix adjust.\n"+
" Identities = 79/126 (63%), Positives = 99/126 (79%), Gaps = 9/126 (7%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVP--MPVR-VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPH  129\n"+
"            + EAV +VL+G+DWTLVP  +P R    + K + H+KRPMNAFMVWAQAARRKL+D + +\n"+
"Sbjct  12   VEEAVVKVLQGFDWTLVPPVVPRRPSLAAQKKRLHIKRPMNAFMVWAQAARRKLSDHHKN  71\n"+
"\n"+
"Query  130  LHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEA  189\n"+
"            LHNAELSKTLGKLW+ L++ EKRPF+EEA+RLR+ HKK++PDYKYQPRRR        + \n"+
"Sbjct  72   LHNAELSKTLGKLWKQLSQEEKRPFIEEADRLRILHKKEYPDYKYQPRRRIR------KE  125\n"+
"\n"+
"Query  190  EEATEQ  195\n"+
"            EE TEQ\n"+
"Sbjct  126  EEHTEQ  131\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KOC68738.1<a name=KOC68738></a> Transcription factor Sox-9-B [Habropoda laboriosa]  \n"+
"Length=311\n"+
"\n"+
" Score = 165 bits (417),  Expect = 5e-44, Method: Compositional matrix adjust.\n"+
" Identities = 75/100 (75%), Positives = 83/100 (83%), Gaps = 2/100 (2%)\n"+
"\n"+
"Query  81   LKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG  140\n"+
"              GYDWTL+P+  R  G  +   HVKRPMNAFMVWAQAARR+LADQYP LHNAELSKTLG\n"+
"Sbjct  140  FTGYDWTLLPVTSRAGG--RRSAHVKRPMNAFMVWAQAARRRLADQYPQLHNAELSKTLG  197\n"+
"\n"+
"Query  141  KLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            KLWR+L++ EK+PFVEEAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  198  KLWRILSDGEKQPFVEEAERLRNAHKKQHPHYKYQPRRRK  237\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACU12319.1<a name=ACU12319></a> Sox9 isoform 3, partial [Crocodylus palustris]  \n"+
"Length=148\n"+
"\n"+
" Score = 159 bits (403),  Expect = 5e-44, Method: Compositional matrix adjust.\n"+
" Identities = 81/88 (92%), Positives = 82/88 (93%), Gaps = 4/88 (5%)\n"+
"\n"+
"Query  248  GKADLKREGRPLPEGGRQPP-IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV  306\n"+
"            GK DLKREGRPLPEGGRQPP IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV\n"+
"Sbjct  1    GKQDLKREGRPLPEGGRQPPHIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV  60\n"+
"\n"+
"Query  307  PATH---GQVTYTGSYGISSTAATPASA  331\n"+
"            PATH   GQVTYTGSYGISSTAATP +A\n"+
"Sbjct  61   PATHGQPGQVTYTGSYGISSTAATPITA  88\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014612515.1<a name=XP_014612515></a> PREDICTED: transcription factor Sox-8-like [Polistes canadensis] \n"+
" \n"+
"Length=363\n"+
"\n"+
" Score = 165 bits (418),  Expect = 1e-43, Method: Compositional matrix adjust.\n"+
" Identities = 78/114 (68%), Positives = 93/114 (82%), Gaps = 8/114 (7%)\n"+
"\n"+
"Query  73   IREAVSQVLK------GYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQ  126\n"+
"            + +AV ++L+      GYDWTL+P+  R  G+ +N  HVKRPMNAFMVWAQAARR+LADQ\n"+
"Sbjct  28   LDDAVGKLLQEYHCCLGYDWTLLPVTSRA-GNRRN-AHVKRPMNAFMVWAQAARRRLADQ  85\n"+
"\n"+
"Query  127  YPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            YP LHNAELSKTLGKLWR+L++ EK+PF+EEAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  86   YPQLHNAELSKTLGKLWRILSDGEKQPFIEEAERLRNAHKKQHPHYKYQPRRRK  139\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014197099.1<a name=XP_014197099></a> PREDICTED: transcription factor SOX-8 [Pan paniscus]  \n"+
"Length=445\n"+
"\n"+
" Score = 165 bits (418),  Expect = 7e-43, Method: Compositional matrix adjust.\n"+
" Identities = 145/369 (39%), Positives = 177/369 (48%), Gaps = 116/369 (31%)\n"+
"\n"+
"Query  145  LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQT-HISPNAI  203\n"+
"            LL+ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS K G ++++   E   H    A+\n"+
"Sbjct  189  LLSESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSAKAGHSDSDSGAELGPHPGGGAV  248\n"+
"\n"+
"Query  204  FKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKA--DLKREGRPLPE  261\n"+
"            +KA         +G+ + H  G+H+GQ+ GPPTPPTTPKT++Q   A  +LK EGR   +\n"+
"Sbjct  249  YKA--------EAGLGDGHHHGDHTGQTHGPPTPPTTPKTELQQAGAKPELKLEGRRPAD  300\n"+
"\n"+
"Query  262  GGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGI  321\n"+
"             GRQ  IDF +VDI ELSS+V+  ++ FDV+EFDQYLP  G    P   GQ  Y G+Y  \n"+
"Sbjct  301  SGRQ-NIDFSNVDISELSSEVMGTMDAFDVHEFDQYLPLGGP--APPEPGQA-YGGAY--  354\n"+
"\n"+
"Query  322  SSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHT  381\n"+
"                   A A  VW  K                AP A   P    P +P           \n"+
"Sbjct  355  -----FHAGASPVWAHKS---------------APSASASPTETGPPRP-----------  383\n"+
"\n"+
"Query  382  LTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYD  441\n"+
"                          HIKTEQ SP HYS+Q + SP                         D\n"+
"Sbjct  384  --------------HIKTEQPSPGHYSDQPRGSP-------------------------D  404\n"+
"\n"+
"Query  442  YTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP-QHWEQ  500\n"+
"            Y      S+Y S                     P+   +A       +P  HSP  HW+Q\n"+
"Sbjct  405  YGSCSGQSTYAS---------------------PLLNGLA-------LPPAHSPTSHWDQ  436\n"+
"\n"+
"Query  501  PVYTQLTRP  509\n"+
"            PVYT LTRP\n"+
"Sbjct  437  PVYTTLTRP  445\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KTF90362.1<a name=KTF90362></a> hypothetical protein cypCar_00036192, partial [Cyprinus carpio] \n"+
" \n"+
"Length=253\n"+
"\n"+
" Score = 160 bits (404),  Expect = 8e-43, Method: Compositional matrix adjust.\n"+
" Identities = 101/161 (63%), Positives = 117/161 (73%), Gaps = 19/161 (12%)\n"+
"\n"+
"Query  146  LNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFK  205\n"+
"            L E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK GQ E    +E TH     ++K\n"+
"Sbjct  1    LTENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKPGQGE----SELTH----HVYK  52\n"+
"\n"+
"Query  206  ALQADSPHSSSGMSEVHSP-GEHSGQSQGPPTPPTTPKTDVQPG-KADLKREGRPLPEGG  263\n"+
"            A         +GM  +  P  +H+GQ  GPPTPPTTPKTD+  G K D K EGR L +G \n"+
"Sbjct  53   A--------EAGMGRLAGPVTDHTGQPHGPPTPPTTPKTDLHHGAKQDPKHEGRRLLDGT  104\n"+
"\n"+
"Query  264  RQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHP  304\n"+
"            RQ  IDF +VDI ELS+DVISN+E+FDV+EFDQYLPP+G P\n"+
"Sbjct  105  RQ-NIDFSNVDISELSTDVISNMESFDVHEFDQYLPPSGQP  144\n"+
"\n"+
"\n"+
" Score = 56.6 bits (135),  Expect = 4e-06, Method: Compositional matrix adjust.\n"+
" Identities = 47/121 (39%), Positives = 63/121 (52%), Gaps = 20/121 (17%)\n"+
"\n"+
"Query  390  GQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSS  449\n"+
"            G   R HIKTEQLSPSHYSE   HS +   YS        PS      +Q DYTD+ +  \n"+
"Sbjct  152  GSQHRAHIKTEQLSPSHYSE---HSAEYGVYSAHACAASFPS------TQCDYTDYYSP-  201\n"+
"\n"+
"Query  450  SYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQ-HWEQPVYTQLTR  508\n"+
"                      +GLY  + Y + ++RP  + + ++    SIP +HSP   W+ PVYT L+R\n"+
"Sbjct  202  -----YPSYPSGLYQ-YPYFHSSRRPYGSNLLNSL---SIPPSHSPSASWDPPVYTTLSR  252\n"+
"\n"+
"Query  509  P  509\n"+
"            P\n"+
"Sbjct  253  P  253\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">JAS10739.1<a name=JAS10739></a> hypothetical protein g.162, partial [Clastoptera arizonana]  \n"+
"\n"+
"Length=181\n"+
"\n"+
" Score = 156 bits (394),  Expect = 3e-42, Method: Compositional matrix adjust.\n"+
" Identities = 68/107 (64%), Positives = 90/107 (84%), Gaps = 1/107 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I+E VS+VL+GYDWT VP+  + + S K K HVKRPMNAFMVWA+ ARR+LA++   +HN\n"+
"Sbjct  20   IQETVSKVLQGYDWTTVPITTK-SASDKRKKHVKRPMNAFMVWAREARRQLANRCSQIHN  78\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            A+LSK LG+LWR L++  K+PF++EAERLR++HK++HPDYKYQPRRR\n"+
"Sbjct  79   AKLSKDLGELWRSLDDRTKKPFIDEAERLRIKHKREHPDYKYQPRRR  125\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KOX79193.1<a name=KOX79193></a> Transcription factor Sox-9-B [Melipona quadrifasciata]  \n"+
"Length=472\n"+
"\n"+
" Score = 162 bits (411),  Expect = 1e-41, Method: Compositional matrix adjust.\n"+
" Identities = 73/101 (72%), Positives = 84/101 (83%), Gaps = 2/101 (2%)\n"+
"\n"+
"Query  80   VLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTL  139\n"+
"             ++ YDWTL+P+  R  G  +   HVKRPMNAFMVWAQAARR+LADQYP LHNAELSKTL\n"+
"Sbjct  169  FVQSYDWTLLPVTSRAGG--RRSAHVKRPMNAFMVWAQAARRRLADQYPQLHNAELSKTL  226\n"+
"\n"+
"Query  140  GKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            GKLWR+L++ EK+PF+EEAERLR  HKK HP YKYQPRRRK\n"+
"Sbjct  227  GKLWRILSDGEKQPFIEEAERLRNAHKKQHPHYKYQPRRRK  267\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014228428.1<a name=XP_014228428></a> PREDICTED: transcription factor Sox-9-B-like [Trichogramma pretiosum] \n"+
" \n"+
"Length=597\n"+
"\n"+
" Score = 165 bits (417),  Expect = 1e-41, Method: Compositional matrix adjust.\n"+
" Identities = 73/111 (66%), Positives = 90/111 (81%), Gaps = 1/111 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV++VL+GYDWTLVP+  +   + K    VKRPMNAFMVWAQAARR LA++YP LHN\n"+
"Sbjct  73   ISAAVAKVLQGYDWTLVPVATK-GANDKRAARVKRPMNAFMVWAQAARRTLAEKYPQLHN  131\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            AELSKTLGK+WRLL+ESEK+PF+++A+ LRV HK  HPDYKYQPRR+   +\n"+
"Sbjct  132  AELSKTLGKVWRLLSESEKKPFIKKADELRVIHKCTHPDYKYQPRRKNGTR  182\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_018027556.1<a name=XP_018027556></a> PREDICTED: transcription factor Sox-8-like [Hyalella azteca] \n"+
" \n"+
"Length=370\n"+
"\n"+
" Score = 159 bits (403),  Expect = 2e-41, Method: Compositional matrix adjust.\n"+
" Identities = 70/110 (64%), Positives = 90/110 (82%), Gaps = 2/110 (2%)\n"+
"\n"+
"Query  64   SEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKL  123\n"+
"            + ED     + +AV+++L GYDW    +PV    +S+++ H+KRPMNAFMVWAQAARRKL\n"+
"Sbjct  19   TAEDMKEAGLDDAVTRLLDGYDW--ASLPVTQKSTSRSRAHIKRPMNAFMVWAQAARRKL  76\n"+
"\n"+
"Query  124  ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYK  173\n"+
"            +DQ+P LHNAELSKTLGKLWR+L++ EK+PF+EEAERLR QHK+DHPDYK\n"+
"Sbjct  77   SDQHPQLHNAELSKTLGKLWRVLSDEEKQPFIEEAERLRTQHKRDHPDYK  126\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AGH69793.1<a name=AGH69793></a> Sox9b-like protein, partial [Anoplopoma fimbria]  \n"+
"Length=156\n"+
"\n"+
" Score = 152 bits (385),  Expect = 3e-41, Method: Compositional matrix adjust.\n"+
" Identities = 107/154 (69%), Positives = 117/154 (76%), Gaps = 7/154 (5%)\n"+
"\n"+
"Query  191  EATEQTHISPNAIFKALQ-ADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGK  249\n"+
"            E  EQTHISP AIFKALQ ADSP SS G  EVHSPGEHSGQSQGPPTPPTTPKTD+   K\n"+
"Sbjct  2    EDGEQTHISPTAIFKALQQADSPASSLG--EVHSPGEHSGQSQGPPTPPTTPKTDLPTSK  59\n"+
"\n"+
"Query  250  ADLKREGRPLPEG-GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPA  308\n"+
"            ADLKREGRP+ EG  RQ  IDF  VDIGELSS+VISN+ +FDV+EFDQYLPP+ H GV  \n"+
"Sbjct  60   ADLKREGRPMQEGTSRQLNIDFGAVDIGELSSEVISNMGSFDVDEFDQYLPPHSHAGVTG  119\n"+
"\n"+
"Query  309  THGQVTYTGSYGISSTAATPAS--AGHVWMSKQQ  340\n"+
"               Q  YT SYGISS++   A+    H WMSKQQ\n"+
"Sbjct  120  A-AQAGYTSSYGISSSSVGHAANVGAHAWMSKQQ  152\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014271239.1<a name=XP_014271239></a> PREDICTED: transcription factor SOX-9-like isoform X1 [Halyomorpha \n"+
"halys]  \n"+
"Length=316\n"+
"\n"+
" Score = 156 bits (395),  Expect = 9e-41, Method: Compositional matrix adjust.\n"+
" Identities = 73/105 (70%), Positives = 86/105 (82%), Gaps = 1/105 (1%)\n"+
"\n"+
"Query  76   AVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAEL  135\n"+
"            AV++ L+ +DW  VP  V  N S K K HVKRPMNAFMVWAQAARR+L+DQYP LHNAEL\n"+
"Sbjct  38   AVNKALQAFDWNQVPR-VTKNSSEKKKAHVKRPMNAFMVWAQAARRRLSDQYPTLHNAEL  96\n"+
"\n"+
"Query  136  SKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            SKTLG+LW+ + + +K+PFV EAERLRV HK+ HPDYKYQPRRRK\n"+
"Sbjct  97   SKTLGQLWKEMADKDKKPFVLEAERLRVVHKRMHPDYKYQPRRRK  141\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EZA48828.1<a name=EZA48828></a> Transcription factor Sox-8 [Cerapachys biroi]  \n"+
"Length=454\n"+
"\n"+
" Score = 159 bits (403),  Expect = 1e-40, Method: Compositional matrix adjust.\n"+
" Identities = 95/182 (52%), Positives = 119/182 (65%), Gaps = 20/182 (11%)\n"+
"\n"+
"Query  60   LKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAA  119\n"+
"            L +   EDK P    +  + V++  D+       R +G  K   HVKRPMNAFMVWAQAA\n"+
"Sbjct  76   LSRMIVEDKMP----KEFNGVMRKNDYA------RGSGD-KRAAHVKRPMNAFMVWAQAA  124\n"+
"\n"+
"Query  120  RRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            RRKLADQYP LHNAELSKTLGKLWRLL++++K+PF+EEA+RLRV HK++HPDYKYQPRRR\n"+
"Sbjct  125  RRKLADQYPQLHNAELSKTLGKLWRLLSDNDKKPFIEEADRLRVIHKREHPDYKYQPRRR  184\n"+
"\n"+
"Query  180  KSVKNGQAEAEE---ATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPT  236\n"+
"            K  +NG A   E   A  Q++++ +      Q D   S  G+   +SP   SG S  PPT\n"+
"Sbjct  185  K--QNGSASTRESSPARNQSNVTFSVSRSLKQED--MSPRGVQGPNSP--QSGVSSSPPT  238\n"+
"\n"+
"Query  237  PP  238\n"+
"             P\n"+
"Sbjct  239  TP  240\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006636968.1<a name=XP_006636968></a> PREDICTED: transcription factor SOX-10, partial [Lepisosteus \n"+
"oculatus]  \n"+
"Length=173\n"+
"\n"+
" Score = 151 bits (382),  Expect = 1e-40, Method: Compositional matrix adjust.\n"+
" Identities = 93/149 (62%), Positives = 110/149 (74%), Gaps = 5/149 (3%)\n"+
"\n"+
"Query  119  ARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRR  178\n"+
"            ARRKLADQYPHLHNAELSKTLGKLWRLLNES+KRPF+EEAERLR QHKKD+P+YKYQPRR\n"+
"Sbjct  1    ARRKLADQYPHLHNAELSKTLGKLWRLLNESDKRPFIEEAERLRKQHKKDYPEYKYQPRR  60\n"+
"\n"+
"Query  179  RKSVKNG-QAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEH---SGQSQGP  234\n"+
"            RK+ K G  AE +  +E       + +K++  D  HS+   S + S G H   +GQS  P\n"+
"Sbjct  61   RKNGKAGPGAEGDAHSEGEVNHSQSHYKSMHLDHAHSAGAGSPL-SDGHHPHAAGQSHSP  119\n"+
"\n"+
"Query  235  PTPPTTPKTDVQPGKADLKREGRPLPEGG  263\n"+
"            PTPPTTPKT++Q GK D  +EGR  PE G\n"+
"Sbjct  120  PTPPTTPKTELQSGKPDRHQEGRASPERG  148\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">OAF68982.1<a name=OAF68982></a> hypothetical protein A3Q56_03272 [Intoshia linei]  \n"+
"Length=326\n"+
"\n"+
" Score = 156 bits (394),  Expect = 2e-40, Method: Compositional matrix adjust.\n"+
" Identities = 75/130 (58%), Positives = 96/130 (74%), Gaps = 4/130 (3%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTL-VPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLH  131\n"+
"            ++E V ++L+GY W+L       +N   +++ H+KRPMNAFMVWAQAAR+KLAD +PHL \n"+
"Sbjct  57   LQEFVDKLLEGYTWSLNKDRENFLNKKFRSRDHIKRPMNAFMVWAQAARKKLADDFPHLR  116\n"+
"\n"+
"Query  132  NAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEE  191\n"+
"            N ELSKTLGKLW++L   EK+PF+EEAERLRV+HK DHP YKY+P RRKSVK+   E + \n"+
"Sbjct  117  NTELSKTLGKLWKILKPEEKKPFIEEAERLRVKHKMDHPQYKYKP-RRKSVKDLTDEDDI  175\n"+
"\n"+
"Query  192  ATEQT--HIS  199\n"+
"              E    HIS\n"+
"Sbjct  176  NVENIINHIS  185\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACU12325.1<a name=ACU12325></a> Sox9 isoform 9, partial [Crocodylus palustris]  \n"+
"Length=82\n"+
"\n"+
" Score = 148 bits (373),  Expect = 2e-40, Method: Compositional matrix adjust.\n"+
" Identities = 75/81 (93%), Positives = 76/81 (94%), Gaps = 4/81 (5%)\n"+
"\n"+
"Query  248  GKADLKREGRPLPEGGRQPP-IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV  306\n"+
"            GK DLKREGRPLPEGGRQPP IDFRDVDIGELSSDVIS+IETFDVNEFDQYLPPNGHPGV\n"+
"Sbjct  1    GKQDLKREGRPLPEGGRQPPHIDFRDVDIGELSSDVISSIETFDVNEFDQYLPPNGHPGV  60\n"+
"\n"+
"Query  307  PATH---GQVTYTGSYGISST  324\n"+
"            PATH   GQVTYTGSYGISST\n"+
"Sbjct  61   PATHGQPGQVTYTGSYGISST  81\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012156196.1<a name=XP_012156196></a> PREDICTED: putative GPI-anchored protein PB15E9.01c [Ceratitis \n"+
"capitata]  \n"+
"Length=793\n"+
"\n"+
" Score = 163 bits (413),  Expect = 2e-40, Method: Compositional matrix adjust.\n"+
" Identities = 81/172 (47%), Positives = 109/172 (63%), Gaps = 10/172 (6%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV +VL+GYDW LV    +V  S + K H+KRPMNAFMVWAQAARR ++ QYPHL N\n"+
"Sbjct  47   ITTAVMKVLEGYDWNLVQATAKVP-SDRKKDHIKRPMNAFMVWAQAARRVMSKQYPHLQN  105\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEA  192\n"+
"            +ELSK+LGKLW+ L ES+K+PF+E AE+LR+ HK++HPDYKYQPRR+K+          A\n"+
"Sbjct  106  SELSKSLGKLWKNLKESDKKPFMEFAEKLRLTHKQEHPDYKYQPRRKKA---------RA  156\n"+
"\n"+
"Query  193  TEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTD  244\n"+
"               + I  + +  A  A+ P +++ MS  +             T PTT   +\n"+
"Sbjct  157  LTVSGIQCDEVLSASGANPPSTTTKMSNANVSSSQLSTDCISGTTPTTKACN  208\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011878279.1<a name=XP_011878279></a> PREDICTED: transcription factor SOX-9-like isoform X3 [Vollenhovia \n"+
"emeryi]  \n"+
"Length=390\n"+
"\n"+
" Score = 157 bits (397),  Expect = 2e-40, Method: Compositional matrix adjust.\n"+
" Identities = 107/257 (42%), Positives = 140/257 (54%), Gaps = 61/257 (24%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K   HVKRPMNAFMVWAQAARRKLADQYP LHNAELSKTLGKLWRLL++++K+PF+EEA+\n"+
"Sbjct  37   KRAAHVKRPMNAFMVWAQAARRKLADQYPQLHNAELSKTLGKLWRLLSDNDKKPFIEEAD  96\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEAT---EQTHISPNAIFKALQADSPHSSS  216\n"+
"            RLRV HK++HPDYKYQPRRRK  +NG +   E++    Q++++ +      Q D      \n"+
"Sbjct  97   RLRVIHKREHPDYKYQPRRRK--QNGPSSGRESSPTRSQSNVTFSVTRSLKQED------  148\n"+
"\n"+
"Query  217  GMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGR------------PLPE---  261\n"+
"             MS     G +S QS    +PPTTP   + P        G+             LP+   \n"+
"Sbjct  149  -MSPRGVQGPNSPQSGVSSSPPTTPGHGLSPPTPPTTPRGQHYINQTLDLQSNQLPQNNT  207\n"+
"\n"+
"Query  262  -------GG--------RQPPIDFRDVDIGE-----------------LSSDVISNIETF  289\n"+
"                   GG        +QP +D R +++G+                 L  ++  N +  \n"+
"Sbjct  208  VYYQELVGGTPSSESPHQQPAVDLRYIEVGDGLPGEENQLNGLGTLGGLGLNLPVNFQEC  267\n"+
"\n"+
"Query  290  DV--NEFDQYLPPNGHP  304\n"+
"            +V  NE DQYLPP   P\n"+
"Sbjct  268  EVESNELDQYLPPQTAP  284\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AIU56789.1<a name=AIU56789></a> Sox9, partial [Huso huso]  \n"+
"Length=100\n"+
"\n"+
" Score = 148 bits (373),  Expect = 3e-40, Method: Compositional matrix adjust.\n"+
" Identities = 89/100 (89%), Positives = 93/100 (93%), Gaps = 1/100 (1%)\n"+
"\n"+
"Query  145  LLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIF  204\n"+
"            LLNE EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQ EAE+ +EQ+HISP AIF\n"+
"Sbjct  1    LLNEGEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQNEAEDGSEQSHISPTAIF  60\n"+
"\n"+
"Query  205  KAL-QADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKT  243\n"+
"            KAL QADS HS+S MSEVHSPGEHSGQSQGPPTPPTTPKT\n"+
"Sbjct  61   KALQQADSSHSASSMSEVHSPGEHSGQSQGPPTPPTTPKT  100\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_003741217.1<a name=XP_003741217></a> PREDICTED: uncharacterized protein LOC100903215 [Metaseiulus \n"+
"occidentalis]  \n"+
"Length=307\n"+
"\n"+
" Score = 155 bits (391),  Expect = 3e-40, Method: Compositional matrix adjust.\n"+
" Identities = 72/110 (65%), Positives = 92/110 (84%), Gaps = 3/110 (3%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVP--MPVRVN-GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPH  129\n"+
"            + EAV +VL+G+DW LVP  +P R +  + K + H+KRPMNAFMVWAQAARRKL+D + +\n"+
"Sbjct  13   VEEAVVKVLQGFDWALVPPVVPRRPSLAAQKRRLHIKRPMNAFMVWAQAARRKLSDHHKN  72\n"+
"\n"+
"Query  130  LHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            LHNAELSKTLGKLW+ L++ EKRPF+EEA+RLR  HKK++PDYKYQPRR+\n"+
"Sbjct  73   LHNAELSKTLGKLWKKLSDEEKRPFIEEADRLRNLHKKEYPDYKYQPRRK  122\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002430276.1<a name=XP_002430276></a> Sex-determining region Y protein, putative [Pediculus humanus \n"+
"corporis]\n"+
" EEB17538.1<a name=EEB17538></a> Sex-determining region Y protein, putative [Pediculus humanus \n"+
"corporis]  \n"+
"Length=289\n"+
"\n"+
" Score = 154 bits (388),  Expect = 4e-40, Method: Compositional matrix adjust.\n"+
" Identities = 70/90 (78%), Positives = 77/90 (86%), Gaps = 0/90 (0%)\n"+
"\n"+
"Query  91   MPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESE  150\n"+
"            +PV     SK K H+KRPMNAFMVWAQAARRKLADQYP LHNAELSKTLGKLWR+L++ E\n"+
"Sbjct  2    LPVTHKSGSKRKEHIKRPMNAFMVWAQAARRKLADQYPQLHNAELSKTLGKLWRILSDEE  61\n"+
"\n"+
"Query  151  KRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            K PF++EAERLR  HKK HPDYKYQPRRRK\n"+
"Sbjct  62   KLPFIDEAERLRNAHKKQHPDYKYQPRRRK  91\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAY54014.1<a name=AAY54014></a> Sox10a, partial [Haplochromis burtoni]  \n"+
"Length=127\n"+
"\n"+
" Score = 148 bits (374),  Expect = 5e-40, Method: Compositional matrix adjust.\n"+
" Identities = 73/116 (63%), Positives = 80/116 (69%), Gaps = 12/116 (10%)\n"+
"\n"+
"Query  20   GAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQ  79\n"+
"            G  SP   +    + C  GS  D             G P  K+E E+D+FP+ IREAVSQ\n"+
"Sbjct  24   GQDSPLTGQQQLTALCVDGSSDDG------------GRPRAKEEEEDDRFPIGIREAVSQ  71\n"+
"\n"+
"Query  80   VLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAEL  135\n"+
"            VL GYDWTLVPMPVRVN  +K KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAEL\n"+
"Sbjct  72   VLDGYDWTLVPMPVRVNNGNKAKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAEL  127\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015521625.1<a name=XP_015521625></a> PREDICTED: transcription factor SOX-8-like [Neodiprion lecontei] \n"+
" \n"+
"Length=375\n"+
"\n"+
" Score = 155 bits (392),  Expect = 8e-40, Method: Compositional matrix adjust.\n"+
" Identities = 73/116 (63%), Positives = 89/116 (77%), Gaps = 2/116 (2%)\n"+
"\n"+
"Query  72   CIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLH  131\n"+
"             I   +  V   YDWTL+P+  + +G  +   H+KRPMNAFMVWAQAARRKL+ QYPHLH\n"+
"Sbjct  36   LISHLLVAVSLSYDWTLLPVTSKASG--RRGGHIKRPMNAFMVWAQAARRKLSYQYPHLH  93\n"+
"\n"+
"Query  132  NAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQA  187\n"+
"            N+ELSKTLGKLWR+L++ +K+PFVEEA+RLR  HKK HP+YKYQPRRRK     QA\n"+
"Sbjct  94   NSELSKTLGKLWRILSDRDKQPFVEEAQRLRSAHKKQHPEYKYQPRRRKQKLAEQA  149\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011212520.1<a name=XP_011212520></a> PREDICTED: mucin-21 [Bactrocera dorsalis]  \n"+
"Length=772\n"+
"\n"+
" Score = 161 bits (408),  Expect = 9e-40, Method: Compositional matrix adjust.\n"+
" Identities = 74/126 (59%), Positives = 95/126 (75%), Gaps = 7/126 (6%)\n"+
"\n"+
"Query  56   GEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVW  115\n"+
"            G  + +KE E       I  AV +VL+GYDW LV    +V  S + K H+KRPMNAFMVW\n"+
"Sbjct  36   GVGNGRKEDER------ITTAVMKVLEGYDWNLVQATAKVP-SDRKKDHIKRPMNAFMVW  88\n"+
"\n"+
"Query  116  AQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQ  175\n"+
"            AQAARR ++ QYPHL N+ELSK+LGKLW+ L ES+K+PF+E AE+LR+ HK++HPDYKYQ\n"+
"Sbjct  89   AQAARRVMSKQYPHLQNSELSKSLGKLWKNLKESDKKPFMEFAEKLRLTHKQEHPDYKYQ  148\n"+
"\n"+
"Query  176  PRRRKS  181\n"+
"            PRR+K+\n"+
"Sbjct  149  PRRKKA  154\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">JAN80589.1<a name=JAN80589></a> Transcription factor Sox-9-A [Daphnia magna]  \n"+
"Length=627\n"+
"\n"+
" Score = 159 bits (401),  Expect = 3e-39, Method: Compositional matrix adjust.\n"+
" Identities = 75/129 (58%), Positives = 90/129 (70%), Gaps = 21/129 (16%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYP----  128\n"+
"            I  AV++VL+GYDW LVP+    +   K   HVKRPMNAFMVWAQ ARR+LADQYP    \n"+
"Sbjct  62   IGNAVAKVLQGYDWNLVPLASSRSNPEKRDTHVKRPMNAFMVWAQEARRQLADQYPQLHN  121\n"+
"\n"+
"Query  129  -----------------HLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPD  171\n"+
"                              LHNAELSKTLG+LWR+L++ +KRPFV++AERLR  HK++HPD\n"+
"Sbjct  122  AELSKTLGRLWRVLSXXQLHNAELSKTLGRLWRVLSDDDKRPFVKQAERLRELHKQEHPD  181\n"+
"\n"+
"Query  172  YKYQPRRRK  180\n"+
"            YKYQPRRRK\n"+
"Sbjct  182  YKYQPRRRK  190\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACF06318.1<a name=ACF06318></a> Sox9, partial [Oncorhynchus mykiss]\n"+
" ACF06319.1<a name=ACF06319></a> Sox9, partial [Oncorhynchus mykiss]\n"+
" ACF06320.1<a name=ACF06320></a> Sox9, partial [Oncorhynchus mykiss]\n"+
" ACF06321.1<a name=ACF06321></a> Sox9, partial [Oncorhynchus mykiss]  \n"+
"Length=101\n"+
"\n"+
" Score = 144 bits (364),  Expect = 5e-39, Method: Compositional matrix adjust.\n"+
" Identities = 85/103 (83%), Positives = 87/103 (84%), Gaps = 4/103 (4%)\n"+
"\n"+
"Query  197  HISPNAIFKALQ-ADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKRE  255\n"+
"            HIS   IFKALQ ADSP SS  M EVHSP EHSGQSQGPPTPPTTPKTD+  GKADLKRE\n"+
"Sbjct  1    HISSGDIFKALQQADSPASS--MGEVHSPSEHSGQSQGPPTPPTTPKTDLAVGKADLKRE  58\n"+
"\n"+
"Query  256  GRPLPEG-GRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQY  297\n"+
"            GRPL EG GRQ  IDFRDVDIGELSSDVISNIE FDV+EFDQY\n"+
"Sbjct  59   GRPLQEGTGRQLNIDFRDVDIGELSSDVISNIEAFDVHEFDQY  101\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017037366.1<a name=XP_017037366></a> PREDICTED: transcription factor SOX-8 [Drosophila kikkawai]  \n"+
"\n"+
"Length=570\n"+
"\n"+
" Score = 156 bits (395),  Expect = 9e-39, Method: Compositional matrix adjust.\n"+
" Identities = 67/109 (61%), Positives = 88/109 (81%), Gaps = 1/109 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV +VL+GYDW LV    +   + + K H+KRPMNAFMVWAQAARR ++ QYPHL N\n"+
"Sbjct  46   ITSAVMKVLEGYDWNLVQASAKAP-TDRKKEHIKRPMNAFMVWAQAARRVMSKQYPHLQN  104\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS  181\n"+
"            +ELSK+LGKLW+ L +S+K+PF+E AE+LR+ HK++HPDYKYQPRR+K+\n"+
"Sbjct  105  SELSKSLGKLWKNLKDSDKKPFMEFAEKLRMTHKQEHPDYKYQPRRKKA  153\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002071990.2<a name=XP_002071990></a> uncharacterized protein Dwil_GK22609 [Drosophila willistoni]\n"+
" EDW82976.2<a name=EDW82976></a> uncharacterized protein Dwil_GK22609 [Drosophila willistoni] \n"+
" \n"+
"Length=477\n"+
"\n"+
" Score = 154 bits (388),  Expect = 2e-38, Method: Compositional matrix adjust.\n"+
" Identities = 67/109 (61%), Positives = 88/109 (81%), Gaps = 1/109 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV +VL+GYDW LV    +   + + K H+KRPMNAFMVWAQAARR ++ QYPHL N\n"+
"Sbjct  44   ITSAVMKVLEGYDWNLVQASAKA-PTDRKKEHIKRPMNAFMVWAQAARRVMSKQYPHLQN  102\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS  181\n"+
"            +ELSK+LGKLW+ L +S+K+PF+E AE+LR+ HK++HPDYKYQPRR+K+\n"+
"Sbjct  103  SELSKSLGKLWKNLKDSDKKPFMEFAEKLRMTHKQEHPDYKYQPRRKKA  151\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAO39384.1<a name=AAO39384></a> transcription factor sox-9, partial [Turdus merula]  \n"+
"Length=143\n"+
"\n"+
" Score = 144 bits (363),  Expect = 3e-38, Method: Compositional matrix adjust.\n"+
" Identities = 104/174 (60%), Positives = 107/174 (61%), Gaps = 37/174 (21%)\n"+
"\n"+
"Query  266  PPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTA  325\n"+
"            P IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPG P   GQVTYTGSYGIS  A\n"+
"Sbjct  1    PHIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGQP---GQVTYTGSYGISGAA  57\n"+
"\n"+
"Query  326  ATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTL  385\n"+
"             TP+SAGHVWM KQ      PQ    A  A Q P Q Q                      \n"+
"Sbjct  58   GTPSSAGHVWMGKQAP-AAQPQPQLPALGAEQGPQQQQQQ--------------------  96\n"+
"\n"+
"Query  386  SSEPGQSQRTHIKTEQLSPSHY------SEQQQHSPQQIAYSPFNLPHYSPSYP  433\n"+
"                   QRTHIKTEQLSPSHY      S QQQ   QQ++YS FNL HYS SYP\n"+
"Sbjct  97   -------QRTHIKTEQLSPSHYSEQQQHSPQQQQQQQQLSYSSFNLQHYSSSYP  143\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACU12329.1<a name=ACU12329></a> Sox9 isoform 13, partial [Crocodylus palustris]  \n"+
"Length=141\n"+
"\n"+
" Score = 143 bits (361),  Expect = 5e-38, Method: Compositional matrix adjust.\n"+
" Identities = 70/75 (93%), Positives = 70/75 (93%), Gaps = 4/75 (5%)\n"+
"\n"+
"Query  248  GKADLKREGRPLPEGGRQPP-IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV  306\n"+
"            GK DLKREGRPLPEGGRQPP IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV\n"+
"Sbjct  1    GKQDLKREGRPLPEGGRQPPHIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV  60\n"+
"\n"+
"Query  307  PATH---GQVTYTGS  318\n"+
"            PATH   GQVTYTGS\n"+
"Sbjct  61   PATHGQPGQVTYTGS  75\n"+
"\n"+
"\n"+
" Score = 117 bits (292),  Expect = 3e-28, Method: Compositional matrix adjust.\n"+
" Identities = 58/67 (87%), Positives = 60/67 (90%), Gaps = 0/67 (0%)\n"+
"\n"+
"Query  403  SPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGL  462\n"+
"            SPSHYSEQQQHSPQQI YS FNL HYS SYP ITRSQYDYTDHQ+S+SYYSHAAGQ T L\n"+
"Sbjct  75   SPSHYSEQQQHSPQQINYSSFNLQHYSSSYPTITRSQYDYTDHQSSNSYYSHAAGQSTSL  134\n"+
"\n"+
"Query  463  YSTFTYM  469\n"+
"            YSTFTYM\n"+
"Sbjct  135  YSTFTYM  141\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACA50927.1<a name=ACA50927></a> Sox9, partial [Salmo salar]  \n"+
"Length=94\n"+
"\n"+
" Score = 141 bits (356),  Expect = 6e-38, Method: Compositional matrix adjust.\n"+
" Identities = 72/96 (75%), Positives = 79/96 (82%), Gaps = 7/96 (7%)\n"+
"\n"+
"Query  1   MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPD-  59\n"+
"           MNLLDPF+KMTDEQ+K LS APSP+MSEDS GSPCPSGSGSDTENTRP EN    G PD \n"+
"Sbjct  1   MNLLDPFLKMTDEQDKCLSDAPSPSMSEDSVGSPCPSGSGSDTENTRPSENGLLMG-PDG  59\n"+
"\n"+
"Query  60  ----LKKESEEDKFPVCIREAVSQVLKGYDWTLVPM  91\n"+
"                KK+ ++DKFPVCIR+AVSQVLKGY WTLVPM\n"+
"Sbjct  60  PLVEFKKD-DDDKFPVCIRDAVSQVLKGYGWTLVPM  94\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002055929.2<a name=XP_002055929></a> uncharacterized protein Dvir_GJ10502 [Drosophila virilis]\n"+
" EDW59041.2<a name=EDW59041></a> uncharacterized protein Dvir_GJ10502 [Drosophila virilis]  \n"+
"Length=544\n"+
"\n"+
" Score = 154 bits (388),  Expect = 7e-38, Method: Compositional matrix adjust.\n"+
" Identities = 71/116 (61%), Positives = 91/116 (78%), Gaps = 1/116 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV +VL+GYDW LV    +   S + K H+KRPMNAFMVWAQAARR ++ QYPHL N\n"+
"Sbjct  42   ITSAVMKVLEGYDWNLVQASAKA-PSDRKKEHIKRPMNAFMVWAQAARRVMSKQYPHLQN  100\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAE  188\n"+
"            +ELSK+LGKLW+ L +S+K+PF+E AE+LR+ HK++HPDYKYQPRR+K+    QAE\n"+
"Sbjct  101  SELSKSLGKLWKNLKDSDKKPFMEFAEKLRMTHKQEHPDYKYQPRRKKARIMPQAE  156\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACU12322.1<a name=ACU12322></a> Sox9 isoform 6, partial [Crocodylus palustris]  \n"+
"Length=222\n"+
"\n"+
" Score = 145 bits (367),  Expect = 7e-38, Method: Compositional matrix adjust.\n"+
" Identities = 73/78 (94%), Positives = 73/78 (94%), Gaps = 4/78 (5%)\n"+
"\n"+
"Query  248  GKADLKREGRPLPEGGRQPP-IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV  306\n"+
"            GK DLKREGRPLPEGGRQPP IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV\n"+
"Sbjct  1    GKQDLKREGRPLPEGGRQPPHIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV  60\n"+
"\n"+
"Query  307  PATH---GQVTYTGSYGI  321\n"+
"            PATH   GQVTYTGSYGI\n"+
"Sbjct  61   PATHGQPGQVTYTGSYGI  78\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017845374.1<a name=XP_017845374></a> PREDICTED: transcription factor SOX-4 [Drosophila busckii]\n"+
" ALC48024.1<a name=ALC48024></a> Sox100B [Drosophila busckii]  \n"+
"Length=544\n"+
"\n"+
" Score = 153 bits (387),  Expect = 8e-38, Method: Compositional matrix adjust.\n"+
" Identities = 69/116 (59%), Positives = 91/116 (78%), Gaps = 1/116 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV +VL+GYDW LV    +   + + K H+KRPMNAFMVWAQAARR ++ QYPHL N\n"+
"Sbjct  42   ITTAVMKVLEGYDWNLVQASAKA-PTDRKKEHIKRPMNAFMVWAQAARRVMSKQYPHLQN  100\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAE  188\n"+
"            +ELSK+LGKLW+ L +S+K+PF+E AE+LR+ HK++HPDYKYQPRR+K+    Q+E\n"+
"Sbjct  101  SELSKSLGKLWKNLKDSDKKPFMEFAEKLRMTHKQEHPDYKYQPRRKKARIMQQSE  156\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017039353.1<a name=XP_017039353></a> PREDICTED: transcription factor Sox-10 [Drosophila ficusphila] \n"+
" \n"+
"Length=526\n"+
"\n"+
" Score = 153 bits (386),  Expect = 8e-38, Method: Compositional matrix adjust.\n"+
" Identities = 68/109 (62%), Positives = 88/109 (81%), Gaps = 1/109 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV +VL+GYDW LV    +   S + K H+KRPMNAFMVWAQAARR ++ QYPHL N\n"+
"Sbjct  46   ITTAVMKVLEGYDWNLVQASAKAP-SDRKKEHIKRPMNAFMVWAQAARRVMSKQYPHLQN  104\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS  181\n"+
"            +ELSK+LGKLW+ L +S+K+PF+E AE+LR+ HK++HPDYKYQPRR+K+\n"+
"Sbjct  105  SELSKSLGKLWKNLKDSDKKPFMEFAEKLRMTHKQEHPDYKYQPRRKKA  153\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_001357577.2<a name=XP_001357577></a> uncharacterized protein Dpse_GA13810, isoform A [Drosophila pseudoobscura \n"+
"pseudoobscura]\n"+
" EAL26711.2<a name=EAL26711></a> uncharacterized protein Dpse_GA13810, isoform A [Drosophila pseudoobscura \n"+
"pseudoobscura]  \n"+
"Length=570\n"+
"\n"+
" Score = 152 bits (385),  Expect = 2e-37, Method: Compositional matrix adjust.\n"+
" Identities = 67/109 (61%), Positives = 88/109 (81%), Gaps = 1/109 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV +VL+GYDW LV    +   + + K H+KRPMNAFMVWAQAARR ++ QYPHL N\n"+
"Sbjct  46   ITSAVMKVLEGYDWNLVQASAKAP-TDRKKEHIKRPMNAFMVWAQAARRVMSKQYPHLQN  104\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS  181\n"+
"            +ELSK+LGKLW+ L +S+K+PF+E AE+LR+ HK++HPDYKYQPRR+K+\n"+
"Sbjct  105  SELSKSLGKLWKNLKDSDKKPFMEFAEKLRMTHKQEHPDYKYQPRRKKA  153\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_001996162.1<a name=XP_001996162></a> GH13971 [Drosophila grimshawi]\n"+
" EDV90820.1<a name=EDV90820></a> GH13971 [Drosophila grimshawi]  \n"+
"Length=586\n"+
"\n"+
" Score = 152 bits (385),  Expect = 2e-37, Method: Compositional matrix adjust.\n"+
" Identities = 68/109 (62%), Positives = 88/109 (81%), Gaps = 1/109 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV +VL+GYDW LV    +   S + K H+KRPMNAFMVWAQAARR ++ QYPHL N\n"+
"Sbjct  42   ITSAVMKVLEGYDWNLVQASAKA-PSDRKKEHIKRPMNAFMVWAQAARRVMSKQYPHLQN  100\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS  181\n"+
"            +ELSK+LGKLW+ L +S+K+PF+E AE+LR+ HK++HPDYKYQPRR+K+\n"+
"Sbjct  101  SELSKSLGKLWKNLKDSDKKPFMEFAEKLRMTHKQEHPDYKYQPRRKKA  149\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005179606.2<a name=XP_005179606></a> PREDICTED: uncharacterized protein LOC101900714, partial [Musca \n"+
"domestica]  \n"+
"Length=792\n"+
"\n"+
" Score = 153 bits (387),  Expect = 6e-37, Method: Compositional matrix adjust.\n"+
" Identities = 67/108 (62%), Positives = 86/108 (80%), Gaps = 1/108 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV +VL+GYDW LV    +   S + K H+KRPMNAFMVWAQAARR ++ Q+PHL N\n"+
"Sbjct  52   ITSAVMKVLEGYDWNLVQASAK-QPSDRKKEHIKRPMNAFMVWAQAARRVMSQQHPHLQN  110\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            +ELSK+LGKLW+ L +S+K+PF++ AE+LR  HK+DHPDYKYQPRR+K\n"+
"Sbjct  111  SELSKSLGKLWKNLKDSDKQPFMDVAEKLRKTHKQDHPDYKYQPRRKK  158\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KDR20036.1<a name=KDR20036></a> Transcription factor SOX-8 [Zootermopsis nevadensis]  \n"+
"Length=313\n"+
"\n"+
" Score = 146 bits (368),  Expect = 6e-37, Method: Compositional matrix adjust.\n"+
" Identities = 66/79 (84%), Positives = 71/79 (90%), Gaps = 0/79 (0%)\n"+
"\n"+
"Query  109  MNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKD  168\n"+
"            MNAFMVWAQAARRKLADQYP LHNAELSKTLGKLWR+L+E EK+PF+EEAERLR  HKKD\n"+
"Sbjct  1    MNAFMVWAQAARRKLADQYPQLHNAELSKTLGKLWRILSEEEKQPFIEEAERLRSAHKKD  60\n"+
"\n"+
"Query  169  HPDYKYQPRRRKSVKNGQA  187\n"+
"            HPDYKYQPRRRK  K+  A\n"+
"Sbjct  61   HPDYKYQPRRRKPPKSATA  79\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAH66375.1<a name=BAH66375></a> SRY-box containing gene 9 homologue, partial [Pelodiscus sinensis] \n"+
" \n"+
"Length=72\n"+
"\n"+
" Score = 137 bits (346),  Expect = 9e-37, Method: Compositional matrix adjust.\n"+
" Identities = 65/72 (90%), Positives = 69/72 (96%), Gaps = 0/72 (0%)\n"+
"\n"+
"Query  438  SQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQH  497\n"+
"            SQYDYTDHQ+S+SYYSHAAGQ T LYSTFTYM+P QRPMYTPIADT+GVPSIPQTHSPQH\n"+
"Sbjct  1    SQYDYTDHQSSNSYYSHAAGQSTSLYSTFTYMSPTQRPMYTPIADTTGVPSIPQTHSPQH  60\n"+
"\n"+
"Query  498  WEQPVYTQLTRP  509\n"+
"            WEQPVYTQLTRP\n"+
"Sbjct  61   WEQPVYTQLTRP  72\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015796225.1<a name=XP_015796225></a> PREDICTED: transcription factor Sox-10-like, partial [Nothobranchius \n"+
"furzeri]  \n"+
"Length=135\n"+
"\n"+
" Score = 139 bits (350),  Expect = 2e-36, Method: Composition-based stats.\n"+
" Identities = 67/89 (75%), Positives = 77/89 (87%), Gaps = 0/89 (0%)\n"+
"\n"+
"Query  56   GEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVW  115\n"+
"            G   +K + EE++FP  IR+AVSQVL  YDWT+VP+PVRV+  SK+K HVKRPMNAFMVW\n"+
"Sbjct  18   GCSSIKSDDEEERFPSGIRDAVSQVLNCYDWTIVPVPVRVSTGSKSKSHVKRPMNAFMVW  77\n"+
"\n"+
"Query  116  AQAARRKLADQYPHLHNAELSKTLGKLWR  144\n"+
"            AQAARRKLADQ+PHLHNAELSKTLGKLWR\n"+
"Sbjct  78   AQAARRKLADQHPHLHNAELSKTLGKLWR  106\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_001243925.1<a name=NP_001243925></a> SoxE [Bombyx mori]\n"+
" ADZ96251.1<a name=ADZ96251></a> SoxE [Bombyx mori]  \n"+
"Length=222\n"+
"\n"+
" Score = 141 bits (356),  Expect = 3e-36, Method: Compositional matrix adjust.\n"+
" Identities = 77/160 (48%), Positives = 107/160 (67%), Gaps = 11/160 (7%)\n"+
"\n"+
"Query  61   KKESEEDKFPVCIREAVSQVLKGYDW-TLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAA  119\n"+
"            +++  EDK    I EAV +++K +D+ T++P P +  G    +PHVKRPMNAFMV+AQA \n"+
"Sbjct  6    ERDRSEDKLE--INEAVGKLVKIFDYDTILPQPTK-GGGCMRRPHVKRPMNAFMVFAQAM  62\n"+
"\n"+
"Query  120  RRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            RR+L+ + P  HNAELSK+LG +W+ L+E EK PF++EA++LR QHKK HPDYKYQPRRR\n"+
"Sbjct  63   RRRLSAERPSPHNAELSKSLGSMWKNLSEEEKLPFIKEADKLRTQHKKQHPDYKYQPRRR  122\n"+
"\n"+
"Query  180  K----SVKNGQAEAEEATEQTHISPNA---IFKALQADSP  212\n"+
"            K    S    + + E + ++ HI  +    I  AL  D P\n"+
"Sbjct  123  KPPLASASTPRVKRESSPDRNHIDFSGMPEISAALLMDGP  162\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013101706.1<a name=XP_013101706></a> PREDICTED: uncharacterized protein LOC106083315 [Stomoxys calcitrans] \n"+
" \n"+
"Length=824\n"+
"\n"+
" Score = 151 bits (381),  Expect = 4e-36, Method: Compositional matrix adjust.\n"+
" Identities = 70/125 (56%), Positives = 93/125 (74%), Gaps = 6/125 (5%)\n"+
"\n"+
"Query  56   GEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVW  115\n"+
"            GE  + ++ +E      I  AV +VL+GYDW LV    +   S + K H+KRPMNAFMVW\n"+
"Sbjct  39   GECGVGRKEDER-----ITSAVMKVLEGYDWNLVQASAK-QPSDRKKEHIKRPMNAFMVW  92\n"+
"\n"+
"Query  116  AQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQ  175\n"+
"            AQAARR ++ Q+PHL N+ELSK+LGKLW+ L +S+K+PF++ AE+LR  HK+DHPDYKYQ\n"+
"Sbjct  93   AQAARRVMSQQHPHLQNSELSKSLGKLWKNLKDSDKQPFMDVAEKLRKTHKQDHPDYKYQ  152\n"+
"\n"+
"Query  176  PRRRK  180\n"+
"            PRR+K\n"+
"Sbjct  153  PRRKK  157\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAY54016.1<a name=AAY54016></a> Sox10b, partial [Haplochromis burtoni]  \n"+
"Length=127\n"+
"\n"+
" Score = 137 bits (346),  Expect = 4e-36, Method: Compositional matrix adjust.\n"+
" Identities = 62/80 (78%), Positives = 69/80 (86%), Gaps = 0/80 (0%)\n"+
"\n"+
"Query  56   GEPDLKKESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVW  115\n"+
"            G   +K + E+D+FP  IR+AVSQVLK YDWTLVPMPVRV+  SKNK HVKRPMNAFMVW\n"+
"Sbjct  48   GCSSVKSDDEDDRFPAGIRDAVSQVLKCYDWTLVPMPVRVSSGSKNKQHVKRPMNAFMVW  107\n"+
"\n"+
"Query  116  AQAARRKLADQYPHLHNAEL  135\n"+
"            AQAARRKLADQ+PHLHNAEL\n"+
"Sbjct  108  AQAARRKLADQHPHLHNAEL  127\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_008695278.1<a name=XP_008695278></a> PREDICTED: transcription factor SOX-8, partial [Ursus maritimus] \n"+
" \n"+
"Length=188\n"+
"\n"+
" Score = 139 bits (351),  Expect = 6e-36, Method: Compositional matrix adjust.\n"+
" Identities = 72/119 (61%), Positives = 84/119 (71%), Gaps = 12/119 (10%)\n"+
"\n"+
"Query  112  FMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPD  171\n"+
"            FMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLL+ESEKRPFVEEAERLRVQHKKDHPD\n"+
"Sbjct  1    FMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLSESEKRPFVEEAERLRVQHKKDHPD  60\n"+
"\n"+
"Query  172  YKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQ  230\n"+
"            YKY           Q +++   E      +A++KA         +G+ + H   +H+GQ\n"+
"Sbjct  61   YKYX----XXXXXXQGDSDSGAELGPHPGSAVYKA--------DAGLGDPHHHSDHTGQ  107\n"+
"\n"+
"\n"+
" Score = 47.0 bits (110),  Expect = 0.003, Method: Compositional matrix adjust.\n"+
" Identities = 34/70 (49%), Positives = 45/70 (64%), Gaps = 6/70 (9%)\n"+
"\n"+
"Query  441  DYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSP-QHWE  499\n"+
"            DYTD Q + SYYS   G  + LY    Y +P++RP  +P+   SG+ S+P  HSP  +W+\n"+
"Sbjct  124  DYTDLQ-APSYYSPYPGCPSSLYQC-PYFHPSRRPYASPL--LSGL-SVPPAHSPPGNWD  178\n"+
"\n"+
"Query  500  QPVYTQLTRP  509\n"+
"            QPVYT LTRP\n"+
"Sbjct  179  QPVYTTLTRP  188\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AIA23790.1<a name=AIA23790></a> Sox3 [Mnemiopsis leidyi]  \n"+
"Length=465\n"+
"\n"+
" Score = 145 bits (367),  Expect = 2e-35, Method: Compositional matrix adjust.\n"+
" Identities = 68/131 (52%), Positives = 98/131 (75%), Gaps = 4/131 (3%)\n"+
"\n"+
"Query  77   VSQVLKGYDWTLVPMPVRVNGSSKN-KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAEL  135\n"+
"            + +++K ++W + P  V     + +    +KRPMNAFMVWAQAARRKLA+++P+LHNAEL\n"+
"Sbjct  15   IMEIIKSFNWNITPDRVDYTTLADDGTKRIKRPMNAFMVWAQAARRKLAERHPYLHNAEL  74\n"+
"\n"+
"Query  136  SKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS--VKNGQA-EAEEA  192\n"+
"            SKTLGK+W+ L+E +KRPFV+EAERLR QH+++HP+YKY+P+RRKS  +K  Q  EA   \n"+
"Sbjct  75   SKTLGKVWKQLSEPDKRPFVDEAERLRQQHRREHPEYKYRPKRRKSSPLKGIQIDEAISL  134\n"+
"\n"+
"Query  193  TEQTHISPNAI  203\n"+
"             E+T +  + +\n"+
"Sbjct  135  KEETDVQRSCL  145\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AIA23791.1<a name=AIA23791></a> Sox4 [Mnemiopsis leidyi]  \n"+
"Length=427\n"+
"\n"+
" Score = 145 bits (365),  Expect = 2e-35, Method: Compositional matrix adjust.\n"+
" Identities = 73/137 (53%), Positives = 98/137 (72%), Gaps = 6/137 (4%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVWAQ+ARRKLADQYP LHNAELSKTLGKLWR+L+E++K P+++E+ERLR+\n"+
"Sbjct  47   HVKRPMNAFMVWAQSARRKLADQYPDLHNAELSKTLGKLWRMLSETDKHPYIKESERLRM  106\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQA----EAEEATEQTHISPNAIFKA-LQADSPHSSSGM  218\n"+
"             HKK HP+YKY+P++RK +K        E E   ++  ++P+  F A  +A     ++ M\n"+
"Sbjct  107  IHKKQHPEYKYRPKKRKHLKRPTERLPHEIETLAKRALLNPDHDFTANTRALMSQQNACM  166\n"+
"\n"+
"Query  219  S-EVHSPGEHSGQSQGP  234\n"+
"            S +   PG   G S+ P\n"+
"Sbjct  167  SPDSTIPGSDVGSSRQP  183\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ABN58458.1<a name=ABN58458></a> SoxE, partial [Branchiostoma lanceolatum]  \n"+
"Length=114\n"+
"\n"+
" Score = 135 bits (340),  Expect = 2e-35, Method: Compositional matrix adjust.\n"+
" Identities = 62/66 (94%), Positives = 63/66 (95%), Gaps = 0/66 (0%)\n"+
"\n"+
"Query  68   KFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQY  127\n"+
"            KFP  IREAVS VLKGYDWTLVPMPVRVNGSSK+KPHVKRPMNAFMVWAQAARRKLADQY\n"+
"Sbjct  49   KFPSQIREAVSNVLKGYDWTLVPMPVRVNGSSKSKPHVKRPMNAFMVWAQAARRKLADQY  108\n"+
"\n"+
"Query  128  PHLHNA  133\n"+
"            PHLHNA\n"+
"Sbjct  109  PHLHNA  114\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017088795.1<a name=XP_017088795></a> PREDICTED: transcription factor SOX-4 isoform X1 [Drosophila \n"+
"bipectinata]  \n"+
"Length=551\n"+
"\n"+
" Score = 146 bits (369),  Expect = 3e-35, Method: Compositional matrix adjust.\n"+
" Identities = 68/117 (58%), Positives = 88/117 (75%), Gaps = 9/117 (8%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV +VL+GYDW LV    +   + + K H+KRPMNAFMVWAQAARR ++ QYPHL N\n"+
"Sbjct  46   ITSAVMKVLEGYDWNLVQASAKAP-TDRKKEHIKRPMNAFMVWAQAARRVMSKQYPHLQN  104\n"+
"\n"+
"Query  133  AELSKTLGKLW--------RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS  181\n"+
"            +ELSK+LGKLW        R L +S+K+PF+E AE+LR+ HK++HPDYKYQPRR+K+\n"+
"Sbjct  105  SELSKSLGKLWNHLFVAFCRNLKDSDKKPFMEFAEKLRMTHKQEHPDYKYQPRRKKA  161\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015138178.1<a name=XP_015138178></a> PREDICTED: transcription factor SOX-17-like [Gallus gallus]  \n"+
"\n"+
"Length=410\n"+
"\n"+
" Score = 143 bits (361),  Expect = 4e-35, Method: Compositional matrix adjust.\n"+
" Identities = 64/90 (71%), Positives = 73/90 (81%), Gaps = 0/90 (0%)\n"+
"\n"+
"Query  95   VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"              G  K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+ +EKRPF\n"+
"Sbjct  52   TGGRGKGEARIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALSLAEKRPF  111\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            VEEAERLRVQHKKDHPDYKYQPRRRKSVK \n"+
"Sbjct  112  VEEAERLRVQHKKDHPDYKYQPRRRKSVKR  141\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AGZ62960.1<a name=AGZ62960></a> SRY-box 9, partial [Homo sapiens]  \n"+
"Length=143\n"+
"\n"+
" Score = 135 bits (339),  Expect = 8e-35, Method: Compositional matrix adjust.\n"+
" Identities = 62/71 (87%), Positives = 64/71 (90%), Gaps = 0/71 (0%)\n"+
"\n"+
"Query  1   MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"           MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL\n"+
"Sbjct  1   MNLLDPFMKMTDEQEKGLSGAPSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDL  60\n"+
"\n"+
"Query  61  KKESEEDKFPV  71\n"+
"           K+ +     P \n"+
"Sbjct  61  KRRARRTSSPC  71\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_001634851.1<a name=XP_001634851></a> predicted protein [Nematostella vectensis]\n"+
" EDO42788.1<a name=EDO42788></a> predicted protein, partial [Nematostella vectensis]  \n"+
"Length=97\n"+
"\n"+
" Score = 132 bits (333),  Expect = 1e-34, Method: Compositional matrix adjust.\n"+
" Identities = 62/86 (72%), Positives = 76/86 (88%), Gaps = 1/86 (1%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K  P VKRPMN+FMVWAQ+ARRKLA+QYPH+HNAELSK LGKLWR+L+ +EK+P+V+EA \n"+
"Sbjct  12   KKDPKVKRPMNSFMVWAQSARRKLAEQYPHVHNAELSKMLGKLWRMLSAAEKQPYVDEAA  71\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRR-KSVKN  184\n"+
"            RL  +HK+DHPDYKY+PRRR KS+K \n"+
"Sbjct  72   RLDKRHKEDHPDYKYRPRRRQKSLKR  97\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_018027588.1<a name=XP_018027588></a> PREDICTED: transcription factor SOX-8-like [Hyalella azteca] \n"+
" \n"+
"Length=652\n"+
"\n"+
" Score = 145 bits (366),  Expect = 2e-34, Method: Compositional matrix adjust.\n"+
" Identities = 62/113 (55%), Positives = 87/113 (77%), Gaps = 4/113 (4%)\n"+
"\n"+
"Query  68   KFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQY  127\n"+
"            K    I +AV+++L   DW+++PM      + + K HVKRPMNAFMVWAQ ARRKL+ Q+\n"+
"Sbjct  290  KLGAGISDAVTKILDDVDWSIIPMA----NNGRQKVHVKRPMNAFMVWAQEARRKLSGQH  345\n"+
"\n"+
"Query  128  PHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"              +HNAELSK+LGK+WR + + +KRPF+E A++LR +HK+++P+YKYQPRRRK\n"+
"Sbjct  346  RQVHNAELSKSLGKIWRGMTDDQKRPFIERADQLRQKHKQEYPNYKYQPRRRK  398\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACU12310.1<a name=ACU12310></a> Sox9 isoform 14, partial [Mus musculus]  \n"+
"Length=80\n"+
"\n"+
" Score = 132 bits (331),  Expect = 2e-34, Method: Compositional matrix adjust.\n"+
" Identities = 61/63 (97%), Positives = 61/63 (97%), Gaps = 0/63 (0%)\n"+
"\n"+
"Query  248  GKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP  307\n"+
"            GK DLKREGRPL EGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP\n"+
"Sbjct  1    GKVDLKREGRPLAEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGVP  60\n"+
"\n"+
"Query  308  ATH  310\n"+
"            ATH\n"+
"Sbjct  61   ATH  63\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013792516.1<a name=XP_013792516></a> PREDICTED: transcription factor Sox-8-like, partial [Limulus \n"+
"polyphemus]  \n"+
"Length=129\n"+
"\n"+
" Score = 132 bits (333),  Expect = 4e-34, Method: Compositional matrix adjust.\n"+
" Identities = 63/84 (75%), Positives = 70/84 (83%), Gaps = 2/84 (2%)\n"+
"\n"+
"Query  62   KESEEDK--FPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAA  119\n"+
"            KES E+K  FP  I +AVS+VLKGYDWT VP P + N S K +P+VKRPMNAFMVWAQAA\n"+
"Sbjct  46   KESLENKAGFPPSIHDAVSRVLKGYDWTFVPTPTKHNNSDKRRPYVKRPMNAFMVWAQAA  105\n"+
"\n"+
"Query  120  RRKLADQYPHLHNAELSKTLGKLW  143\n"+
"            RRKLA QYPHLHNAELSKTLG+LW\n"+
"Sbjct  106  RRKLAGQYPHLHNAELSKTLGRLW  129\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KXJ18409.1<a name=KXJ18409></a> Transcription factor Sox-8 [Exaiptasia pallida]  \n"+
"Length=437\n"+
"\n"+
" Score = 140 bits (354),  Expect = 7e-34, Method: Compositional matrix adjust.\n"+
" Identities = 61/85 (72%), Positives = 76/85 (89%), Gaps = 1/85 (1%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K   H+KRPMN+FMVWAQ+ARRKLA+QYPH+HNAELSK LGKLWR+L+ SEK+P+V+EA \n"+
"Sbjct  104  KKDGHIKRPMNSFMVWAQSARRKLAEQYPHVHNAELSKMLGKLWRMLSASEKQPYVDEAA  163\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRR-KSVK  183\n"+
"            RL  +HK+D+PDYKY+PRRR KS+K\n"+
"Sbjct  164  RLDKRHKEDNPDYKYRPRRRQKSLK  188\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009024117.1<a name=XP_009024117></a> hypothetical protein HELRODRAFT_147226, partial [Helobdella robusta]\n"+
" ESN97653.1<a name=ESN97653></a> hypothetical protein HELRODRAFT_147226, partial [Helobdella robusta] \n"+
" \n"+
"Length=75\n"+
"\n"+
" Score = 130 bits (326),  Expect = 8e-34, Method: Compositional matrix adjust.\n"+
" Identities = 58/75 (77%), Positives = 69/75 (92%), Gaps = 0/75 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            +KRPMNAFMVWAQAAR++LADQ+P LHNAELSKTLGKLW+LL++  K+PFV EAE+LR Q\n"+
"Sbjct  1    IKRPMNAFMVWAQAARKRLADQHPQLHNAELSKTLGKLWKLLDDQGKQPFVVEAEKLRQQ  60\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRR  179\n"+
"            H+ DHPDYKYQPRR+\n"+
"Sbjct  61   HRVDHPDYKYQPRRK  75\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ELK28442.1<a name=ELK28442></a> Transcription factor SOX-8 [Myotis davidii]  \n"+
"Length=343\n"+
"\n"+
" Score = 137 bits (346),  Expect = 1e-33, Method: Compositional matrix adjust.\n"+
" Identities = 106/273 (39%), Positives = 139/273 (51%), Gaps = 54/273 (20%)\n"+
"\n"+
"Query  246  QPGKADLKREGRPLPEGGRQPPIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPG  305\n"+
"            Q GK +LK EGR L + GRQ  IDF +VDI ELSS+VI N++TFDV+EFDQYLP NGH  \n"+
"Sbjct  116  QGGKQELKLEGRRLVDSGRQN-IDFSNVDISELSSEVIGNMDTFDVHEFDQYLPLNGHSA  174\n"+
"\n"+
"Query  306  VPATHGQVTYTGSYGISS---TAATPASAGHVWMSKQQAPPPPPQQPPQAPPAPQAPPQP  362\n"+
"            +P   GQ + +GSYG +S   + +    A  VW  K                AP A   P\n"+
"Sbjct  175  LPTEPGQPSTSGSYGGASYSHSGSAGIGASPVWAHKG---------------APSASASP  219\n"+
"\n"+
"Query  363  QAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSP  422\n"+
"              A P +P                         HIKTEQLSP HY +Q   SP +  YS \n"+
"Sbjct  220  TEAGPPRP-------------------------HIKTEQLSPGHYGDQSHSSPGRTDYSS  254\n"+
"\n"+
"Query  423  FNL------PHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQRPM  476\n"+
"            ++          + +    T SQ DYTD Q + +YY+  AG  + LY  + Y + ++RP \n"+
"Sbjct  255  YSAQANVTTAASAAAANSFTSSQCDYTDLQ-APNYYNPYAGYPSSLY-QYPYFHSSRRPY  312\n"+
"\n"+
"Query  477  YTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"             +P+  +  VP  P    P +W+QPVYT LTRP\n"+
"Sbjct  313  TSPLLSSLSVP--PAHSPPSNWDQPVYTTLTRP  343\n"+
"\n"+
"\n"+
" Score = 62.0 bits (149),  Expect = 1e-07, Method: Compositional matrix adjust.\n"+
" Identities = 27/27 (100%), Positives = 27/27 (100%), Gaps = 0/27 (0%)\n"+
"\n"+
"Query  118  AARRKLADQYPHLHNAELSKTLGKLWR  144\n"+
"            AARRKLADQYPHLHNAELSKTLGKLWR\n"+
"Sbjct  47   AARRKLADQYPHLHNAELSKTLGKLWR  73\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACU12332.1<a name=ACU12332></a> Sox 9 isoform 16, partial [Crocodylus palustris]  \n"+
"Length=168\n"+
"\n"+
" Score = 132 bits (332),  Expect = 2e-33, Method: Compositional matrix adjust.\n"+
" Identities = 64/66 (97%), Positives = 64/66 (97%), Gaps = 1/66 (2%)\n"+
"\n"+
"Query  248  GKADLKREGRPLPEGGRQPP-IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV  306\n"+
"            GK DLKREGRPLPEGGRQPP IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV\n"+
"Sbjct  1    GKQDLKREGRPLPEGGRQPPHIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHPGV  60\n"+
"\n"+
"Query  307  PATHGQ  312\n"+
"            PATHGQ\n"+
"Sbjct  61   PATHGQ  66\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AIA23793.1<a name=AIA23793></a> Sox6 [Mnemiopsis leidyi]  \n"+
"Length=406\n"+
"\n"+
" Score = 138 bits (348),  Expect = 2e-33, Method: Compositional matrix adjust.\n"+
" Identities = 59/81 (73%), Positives = 70/81 (86%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW+Q  R+KLADQ+P LHN+ELSK LG LWRLL E EKRPFVE+AERLR \n"+
"Sbjct  18   HVKRPMNAFMVWSQIERKKLADQHPDLHNSELSKMLGHLWRLLTEDEKRPFVEKAERLRA  77\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKN  184\n"+
"            QH ++HP YKY+PRRR+ +K+\n"+
"Sbjct  78   QHMEEHPGYKYRPRRRQQIKH  98\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAH60612.1<a name=AAH60612></a> Sox17 protein [Mus musculus]  \n"+
"Length=176\n"+
"\n"+
" Score = 132 bits (332),  Expect = 2e-33, Method: Compositional matrix adjust.\n"+
" Identities = 60/93 (65%), Positives = 73/93 (78%), Gaps = 0/93 (0%)\n"+
"\n"+
"Query  92   PVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEK  151\n"+
"            P   +G +K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L  +EK\n"+
"Sbjct  55   PAGTSGRAKAESRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALTLAEK  114\n"+
"\n"+
"Query  152  RPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            RPFVEEAERLRVQH +DHP+YKY+PRRRK VK \n"+
"Sbjct  115  RPFVEEAERLRVQHMQDHPNYKYRPRRRKQVKR  147\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KQK84642.1<a name=KQK84642></a> transcription factor SOX-17 [Amazona aestiva]  \n"+
"Length=187\n"+
"\n"+
" Score = 132 bits (331),  Expect = 3e-33, Method: Compositional matrix adjust.\n"+
" Identities = 59/85 (69%), Positives = 71/85 (84%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"             G SK++  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+ SEKRPFV\n"+
"Sbjct  56   GGRSKSEXRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALSLSEKRPFV  115\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            EEAERLRVQH +DHP+YKY+PRRRK\n"+
"Sbjct  116  EEAERLRVQHMQDHPNYKYRPRRRK  140\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009098993.1<a name=XP_009098993></a> PREDICTED: transcription factor SOX-17-like, partial [Serinus \n"+
"canaria]  \n"+
"Length=187\n"+
"\n"+
" Score = 132 bits (331),  Expect = 3e-33, Method: Compositional matrix adjust.\n"+
" Identities = 60/89 (67%), Positives = 72/89 (81%), Gaps = 0/89 (0%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"             G SK +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+ +EKRPFV\n"+
"Sbjct  55   GGRSKGEARIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALSLAEKRPFV  114\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            EEAERLRVQH +DHP+YKY+PRRRK VK \n"+
"Sbjct  115  EEAERLRVQHMQDHPNYKYRPRRRKQVKR  143\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAS29567.1<a name=BAS29567></a> SRY (sex determining region Y)-box9, partial [Homo sapiens]  \n"+
"\n"+
"Length=65\n"+
"\n"+
" Score = 127 bits (319),  Expect = 5e-33, Method: Compositional matrix adjust.\n"+
" Identities = 64/65 (98%), Positives = 64/65 (98%), Gaps = 0/65 (0%)\n"+
"\n"+
"Query  381  TLTTLSSEPGQSQRTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQY  440\n"+
"            TLTTLSSEPGQSQ THIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQY\n"+
"Sbjct  1    TLTTLSSEPGQSQGTHIKTEQLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQY  60\n"+
"\n"+
"Query  441  DYTDH  445\n"+
"            DYTDH\n"+
"Sbjct  61   DYTDH  65\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">CAP40305.1<a name=CAP40305></a> Xsox17-alpha1 protein [Xenopus gilli]  \n"+
"Length=245\n"+
"\n"+
" Score = 133 bits (335),  Expect = 5e-33, Method: Compositional matrix adjust.\n"+
" Identities = 65/106 (61%), Positives = 76/106 (72%), Gaps = 6/106 (6%)\n"+
"\n"+
"Query  95   VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"             N  SK +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L  +EKRPF\n"+
"Sbjct  52   ANSRSKAETRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKSLTLAEKRPF  111\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRRRKSVK------NGQAEAEEATE  194\n"+
"            VEEAERLRVQH +DHP+YKY+PRRRK VK      NG     EA E\n"+
"Sbjct  112  VEEAERLRVQHMQDHPNYKYRPRRRKQVKRMKRTENGFMHMAEAQE  157\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010001878.1<a name=XP_010001878></a> PREDICTED: transcription factor SOX-8 [Chaetura pelagica]  \n"+
"Length=205\n"+
"\n"+
" Score = 132 bits (332),  Expect = 5e-33, Method: Compositional matrix adjust.\n"+
" Identities = 90/148 (61%), Positives = 107/148 (72%), Gaps = 8/148 (5%)\n"+
"\n"+
"Query  136  SKTLGKL-WRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATE  194\n"+
"            S T  KL + LL+E+EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK GQ++++   E\n"+
"Sbjct  5    SSTCCKLIFTLLSENEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKAGQSDSDSGAE  64\n"+
"\n"+
"Query  195  QTHISPNAIFKALQADSPHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPG-KADLK  253\n"+
"             +H     I+K   ADS      M + H  G+H+GQ+ GPPTPPTTPKTD+  G K +LK\n"+
"Sbjct  65   LSHHPGTQIYK---ADS--GLGAMPDSHHHGDHTGQTHGPPTPPTTPKTDLHHGSKQELK  119\n"+
"\n"+
"Query  254  REGRPLPEGGRQPPIDFRDVDIGELSSD  281\n"+
"             EGR L E GRQ  IDF +VDI ELSS+\n"+
"Sbjct  120  HEGRRLVESGRQ-NIDFSNVDISELSSE  146\n"+
"\n"+
"\n"+
" Score = 41.2 bits (95),  Expect = 0.42, Method: Compositional matrix adjust.\n"+
" Identities = 28/62 (45%), Positives = 40/62 (65%), Gaps = 5/62 (8%)\n"+
"\n"+
"Query  449  SSYYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQ-HWEQPVYTQLT  507\n"+
"            S+YY+   G  + +Y  + Y + ++RP  TPI +  G+ SIP  HSP  +W+QPVYT LT\n"+
"Sbjct  148  SNYYNPYPGYPSSIYQ-YPYFHSSRRPYATPILN--GL-SIPPAHSPTANWDQPVYTTLT  203\n"+
"\n"+
"Query  508  RP  509\n"+
"            RP\n"+
"Sbjct  204  RP  205\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015472439.1<a name=XP_015472439></a> PREDICTED: transcription factor SOX-17, partial [Parus major] \n"+
" \n"+
"Length=277\n"+
"\n"+
" Score = 134 bits (336),  Expect = 9e-33, Method: Compositional matrix adjust.\n"+
" Identities = 60/89 (67%), Positives = 72/89 (81%), Gaps = 0/89 (0%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"             G SK +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+ +EKRPFV\n"+
"Sbjct  54   GGRSKGEARIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALSLAEKRPFV  113\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            EEAERLRVQH +DHP+YKY+PRRRK VK \n"+
"Sbjct  114  EEAERLRVQHMQDHPNYKYRPRRRKQVKR  142\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005993498.1<a name=XP_005993498></a> PREDICTED: transcription factor SOX-17 [Latimeria chalumnae] \n"+
" \n"+
"Length=381\n"+
"\n"+
" Score = 136 bits (342),  Expect = 1e-32, Method: Compositional matrix adjust.\n"+
" Identities = 60/85 (71%), Positives = 72/85 (85%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            SK +P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK WR L+ +EKRPFVEEA\n"+
"Sbjct  56   SKTEPRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWRALSLAEKRPFVEEA  115\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ERLR+QH +DHP+YKY+PRRRK VK\n"+
"Sbjct  116  ERLRIQHMQDHPNYKYRPRRRKQVK  140\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009052565.1<a name=XP_009052565></a> hypothetical protein LOTGIDRAFT_88815, partial [Lottia gigantea]\n"+
" ESO96755.1<a name=ESO96755></a> hypothetical protein LOTGIDRAFT_88815, partial [Lottia gigantea] \n"+
" \n"+
"Length=78\n"+
"\n"+
" Score = 126 bits (317),  Expect = 1e-32, Method: Compositional matrix adjust.\n"+
" Identities = 59/79 (75%), Positives = 64/79 (81%), Gaps = 1/79 (1%)\n"+
"\n"+
"Query  66   EDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLAD  125\n"+
"            +  F   I++AV  VLKGYDW+LV  P R  G  K KPH+KRPMNAFMVWAQAARRKLAD\n"+
"Sbjct  1    DSNFASQIQDAVCHVLKGYDWSLVTTPSRA-GGDKRKPHIKRPMNAFMVWAQAARRKLAD  59\n"+
"\n"+
"Query  126  QYPHLHNAELSKTLGKLWR  144\n"+
"            QYPHLHNAELSKTLGKLWR\n"+
"Sbjct  60   QYPHLHNAELSKTLGKLWR  78\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KFP27629.1<a name=KFP27629></a> Transcription factor SOX-10, partial [Colius striatus]  \n"+
"Length=142\n"+
"\n"+
" Score = 129 bits (323),  Expect = 2e-32, Method: Compositional matrix adjust.\n"+
" Identities = 89/144 (62%), Positives = 101/144 (70%), Gaps = 7/144 (5%)\n"+
"\n"+
"Query  144  RLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAI  203\n"+
"            RLLNES+KRPF+EEAERLR+QHKKDHPDYKYQPRRRK+ K  Q E E   E       AI\n"+
"Sbjct  1    RLLNESDKRPFIEEAERLRMQHKKDHPDYKYQPRRRKNGKATQGEGEGQGEGEAGGAAAI  60\n"+
"\n"+
"Query  204  ---FKALQADSPHSSSG--MSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRP  258\n"+
"               +K    D  H   G  MS+ H P   SGQS GPPTPPTTPKT++Q GKAD KREGR \n"+
"Sbjct  61   QAHYKNAHLDHRHPGEGSPMSDGH-PEHSSGQSHGPPTPPTTPKTELQAGKADSKREGRS  119\n"+
"\n"+
"Query  259  LPEGGRQPPIDFRDVDIGELSSDV  282\n"+
"            L EGG+ P IDF +VDIGE+S +V\n"+
"Sbjct  120  LGEGGK-PHIDFGNVDIGEISHEV  142\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015758495.1<a name=XP_015758495></a> PREDICTED: transcription factor SOX-1-like [Acropora digitifera] \n"+
" \n"+
"Length=439\n"+
"\n"+
" Score = 136 bits (342),  Expect = 3e-32, Method: Compositional matrix adjust.\n"+
" Identities = 57/81 (70%), Positives = 72/81 (89%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K + HVKRPMN+FMVWAQ+ARRKLA+QYPH+HNAELSK LGKLWR+L  +EK+P+V+EA \n"+
"Sbjct  104  KKENHVKRPMNSFMVWAQSARRKLAEQYPHVHNAELSKMLGKLWRMLPAAEKQPYVDEAA  163\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RL  +HK++ PDYKY+PRRR+\n"+
"Sbjct  164  RLDKRHKEEFPDYKYRPRRRQ  184\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KQK84643.1<a name=KQK84643></a> transcription factor SOX-17-like protein [Amazona aestiva]  \n"+
"Length=292\n"+
"\n"+
" Score = 132 bits (333),  Expect = 3e-32, Method: Compositional matrix adjust.\n"+
" Identities = 59/85 (69%), Positives = 71/85 (84%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"             G SK++  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+ SEKRPFV\n"+
"Sbjct  56   GGRSKSEARIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALSLSEKRPFV  115\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            EEAERLRVQH +DHP+YKY+PRRRK\n"+
"Sbjct  116  EEAERLRVQHMQDHPNYKYRPRRRK  140\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005479360.1<a name=XP_005479360></a> PREDICTED: transcription factor SOX-17-like [Zonotrichia albicollis] \n"+
" \n"+
"Length=397\n"+
"\n"+
" Score = 135 bits (339),  Expect = 3e-32, Method: Compositional matrix adjust.\n"+
" Identities = 61/89 (69%), Positives = 72/89 (81%), Gaps = 0/89 (0%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"             G SK +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+ SEKRPFV\n"+
"Sbjct  55   GGRSKGEARIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALSLSEKRPFV  114\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            EEAERLRVQH +DHP+YKY+PRRRK VK \n"+
"Sbjct  115  EEAERLRVQHMQDHPNYKYRPRRRKQVKR  143\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AEU10962.1<a name=AEU10962></a> SRY-box containing protein 10, partial [Ceratotherium simum]\n"+
" AEU10963.1<a name=AEU10963></a> SRY-box containing protein 10, partial [Dicerorhinus sumatrensis]\n"+
" AEU10965.1<a name=AEU10965></a> SRY-box containing protein 10, partial [Rhinoceros unicornis] \n"+
" \n"+
"Length=167\n"+
"\n"+
" Score = 129 bits (323),  Expect = 3e-32, Method: Compositional matrix adjust.\n"+
" Identities = 90/216 (42%), Positives = 111/216 (51%), Gaps = 52/216 (24%)\n"+
"\n"+
"Query  297  YLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPAP  356\n"+
"            YLPPNGHPG    H        YG+ S  A  AS    W+SK                  \n"+
"Sbjct  1    YLPPNGHPG----HVGSYSAAGYGLGSALAV-ASGHSAWISK------------------  37\n"+
"\n"+
"Query  357  QAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTEQLSPS---HYSEQQQH  413\n"+
"                                P    L T+S  PG   +  +KTE   P    HY +Q   \n"+
"Sbjct  38   --------------------PPGVALPTVS-PPGVDAKAQVKTETAGPQGPPHYPDQPST  76\n"+
"\n"+
"Query  414  SPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSSYYSHAAGQGTGLYSTFTYMNPAQ  473\n"+
"            S  QIAY+  +LPHY  ++P I+R Q+DY+DHQ S  YY H +GQ +GLYS F+YM P+Q\n"+
"Sbjct  77   S--QIAYTSLSLPHYGSAFPSISRPQFDYSDHQPSGPYYGH-SGQASGLYSAFSYMGPSQ  133\n"+
"\n"+
"Query  474  RPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            RP+YT I+D S  PS PQ+HSP HWEQPVYT L+RP\n"+
"Sbjct  134  RPLYTAISDPS--PSGPQSHSPTHWEQPVYTTLSRP  167\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KFM58735.1<a name=KFM58735></a> Transcription factor Sox-9-B, partial [Stegodyphus mimosarum] \n"+
" \n"+
"Length=119\n"+
"\n"+
" Score = 125 bits (315),  Expect = 1e-31, Method: Compositional matrix adjust.\n"+
" Identities = 57/71 (80%), Positives = 61/71 (86%), Gaps = 0/71 (0%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I+ AVS+VL+ YDW+LV    R  GS K KPHVKRPMNAFMVWAQAARRKLADQYPHLHN\n"+
"Sbjct  49   IQAAVSKVLQSYDWSLVAKTSRQGGSDKRKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  108\n"+
"\n"+
"Query  133  AELSKTLGKLW  143\n"+
"            AELSKTLGKLW\n"+
"Sbjct  109  AELSKTLGKLW  119\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015743638.1<a name=XP_015743638></a> PREDICTED: transcription factor SOX-17-like [Python bivittatus] \n"+
" \n"+
"Length=263\n"+
"\n"+
" Score = 130 bits (327),  Expect = 1e-31, Method: Compositional matrix adjust.\n"+
" Identities = 58/89 (65%), Positives = 71/89 (80%), Gaps = 0/89 (0%)\n"+
"\n"+
"Query  95   VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"             +G +K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LG+ WR L + EKRPF\n"+
"Sbjct  55   ASGRAKGETRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGQSWRALTQEEKRPF  114\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            VEEAERLR+QH +DHP YKY+PRRRK VK\n"+
"Sbjct  115  VEEAERLRLQHMRDHPHYKYRPRRRKQVK  143\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ABS89291.1<a name=ABS89291></a> SRY sex determining region Y-box 9, partial [Trachemys scripta] \n"+
" \n"+
"Length=113\n"+
"\n"+
" Score = 124 bits (312),  Expect = 2e-31, Method: Compositional matrix adjust.\n"+
" Identities = 81/135 (60%), Positives = 85/135 (63%), Gaps = 26/135 (19%)\n"+
"\n"+
"Query  299  PPNGHPGVPATHGQ---VTYTGSYGISSTAATPASAGHVWMSKQQAPPPPPQQPPQAPPA  355\n"+
"            PPNGHPGVPATHGQ   VTY+GSYGISST+AT A AG VWMSKQ                \n"+
"Sbjct  1    PPNGHPGVPATHGQPGQVTYSGSYGISSTSATQAGAGPVWMSKQPP--------------  46\n"+
"\n"+
"Query  356  PQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQ-RTHIKTEQLSPSHYSEQQQHS  414\n"+
"                        Q P         HT+TTLSSE GQSQ RTHIKTEQLSPSHYSEQQQHS\n"+
"Sbjct  47   --------QPQQQPPPPQAPPQPPHTMTTLSSEQGQSQQRTHIKTEQLSPSHYSEQQQHS  98\n"+
"\n"+
"Query  415  PQQIAYSPFNLPHYS  429\n"+
"            PQQ+ YS FN  HYS\n"+
"Sbjct  99   PQQLNYSSFNPQHYS  113\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_989425.1<a name=NP_989425></a> transcription factor Sox-17-alpha [Xenopus tropicalis]\n"+
" Q8AWH3.1<a name=Q8AWH3></a> RecName: Full=Transcription factor Sox-17-alpha; Short=Sox17alpha; \n"+
"Short=tSox17alpha\n"+
" AAN76329.1<a name=AAN76329></a> HMG box transcription factor Sox17-alpha [Xenopus tropicalis]\n"+
" AAH74527.1<a name=AAH74527></a> SRY (sex determining region Y)-box 17 alpha [Xenopus tropicalis]\n"+
" AAT71996.1<a name=AAT71996></a> sox17 alpha [Xenopus tropicalis]\n"+
" CAJ82986.1<a name=CAJ82986></a> SRY (sex determining region Y)-box 17 [Xenopus tropicalis]\n"+
" OCA32197.1<a name=OCA32197></a> hypothetical protein XENTR_v90016800mg [Xenopus tropicalis]  \n"+
"\n"+
"Length=383\n"+
"\n"+
" Score = 132 bits (333),  Expect = 2e-31, Method: Compositional matrix adjust.\n"+
" Identities = 59/89 (66%), Positives = 70/89 (79%), Gaps = 0/89 (0%)\n"+
"\n"+
"Query  95   VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"             N   K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L  +EKRPF\n"+
"Sbjct  51   ANSRGKAEARIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALTLAEKRPF  110\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            VEEAERLRVQH +DHP+YKY+PRRRK VK\n"+
"Sbjct  111  VEEAERLRVQHMQDHPNYKYRPRRRKQVK  139\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_004175324.1<a name=XP_004175324></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-17 [Taeniopygia \n"+
"guttata]  \n"+
"Length=498\n"+
"\n"+
" Score = 134 bits (338),  Expect = 2e-31, Method: Compositional matrix adjust.\n"+
" Identities = 60/89 (67%), Positives = 72/89 (81%), Gaps = 0/89 (0%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"             G SK +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+ +EKRPFV\n"+
"Sbjct  145  GGRSKGEARIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALSLAEKRPFV  204\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            EEAERLRVQH +DHP+YKY+PRRRK VK \n"+
"Sbjct  205  EEAERLRVQHMQDHPNYKYRPRRRKQVKR  233\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_001158450.1<a name=NP_001158450></a> sox7/17 protein [Saccoglossus kowalevskii]\n"+
" ACH73250.1<a name=ACH73250></a> sox7/17 protein [Saccoglossus kowalevskii]  \n"+
"Length=471\n"+
"\n"+
" Score = 134 bits (336),  Expect = 3e-31, Method: Compositional matrix adjust.\n"+
" Identities = 57/81 (70%), Positives = 67/81 (83%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K +P ++RPMNAFMVWA+  R++LADQ P LHNA+LSK LGK WR L+  +KRPFVEEAE\n"+
"Sbjct  24   KKEPRIRRPMNAFMVWAKDERKRLADQNPDLHNADLSKMLGKAWRNLSLVQKRPFVEEAE  83\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRRK  180\n"+
"            RLRVQH  DHPDYKY+PRRR \n"+
"Sbjct  84   RLRVQHMTDHPDYKYRPRRRN  104\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002404127.1<a name=XP_002404127></a> sox10 protein, putative [Ixodes scapularis]\n"+
" EEC11790.1<a name=EEC11790></a> sox10 protein, putative [Ixodes scapularis]  \n"+
"Length=140\n"+
"\n"+
" Score = 125 bits (313),  Expect = 4e-31, Method: Compositional matrix adjust.\n"+
" Identities = 69/123 (56%), Positives = 76/123 (62%), Gaps = 24/123 (20%)\n"+
"\n"+
"Query  22   PSPTMSEDSAGSPCPSGSGSDTENTRPQENTFPKGEPDLKKESEEDKFPVCIREAVSQVL  81\n"+
"            P P   +DS      SG GSD+  T P EN                     I+ AVS+VL\n"+
"Sbjct  42   PGPVFDDDSC-----SGDGSDS-GTDPLENN------------------PGIQAAVSKVL  77\n"+
"\n"+
"Query  82   KGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGK  141\n"+
"            + YDW+LV    R  GS K + HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGK\n"+
"Sbjct  78   QSYDWSLVAKTTRQGGSEKKRLHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGK  137\n"+
"\n"+
"Query  142  LWR  144\n"+
"            LWR\n"+
"Sbjct  138  LWR  140\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002430273.1<a name=XP_002430273></a> sox9, putative [Pediculus humanus corporis]\n"+
" EEB17535.1<a name=EEB17535></a> sox9, putative [Pediculus humanus corporis]  \n"+
"Length=161\n"+
"\n"+
" Score = 125 bits (315),  Expect = 4e-31, Method: Composition-based stats.\n"+
" Identities = 63/92 (68%), Positives = 73/92 (79%), Gaps = 3/92 (3%)\n"+
"\n"+
"Query  98   SSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWR---LLNESEKRPF  154\n"+
"            SS+ K HVKRPMNAFMVWAQAARR+LAD YP LHNAELSKTLG LW    +L+ + K+PF\n"+
"Sbjct  57   SSEKKKHVKRPMNAFMVWAQAARRQLADIYPALHNAELSKTLGTLWSIIIMLSTTCKKPF  116\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQ  186\n"+
"            + EAE+LR  HKK +PDYKYQPRR+K  K G \n"+
"Sbjct  117  ITEAEKLRQVHKKKYPDYKYQPRRKKGSKCGH  148\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012676760.1<a name=XP_012676760></a> PREDICTED: transcription factor SOX-17 [Clupea harengus]  \n"+
"Length=458\n"+
"\n"+
" Score = 133 bits (334),  Expect = 5e-31, Method: Compositional matrix adjust.\n"+
" Identities = 60/89 (67%), Positives = 69/89 (78%), Gaps = 0/89 (0%)\n"+
"\n"+
"Query  95   VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"              G  K +P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L   EKRPF\n"+
"Sbjct  53   ATGRGKTEPRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKSLAVPEKRPF  112\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            VEEAERLRVQH  DHP+YKY+PRRRK VK\n"+
"Sbjct  113  VEEAERLRVQHMHDHPNYKYRPRRRKQVK  141\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005301251.1<a name=XP_005301251></a> PREDICTED: transcription factor SOX-17-like [Chrysemys picta \n"+
"bellii]  \n"+
"Length=388\n"+
"\n"+
" Score = 131 bits (330),  Expect = 5e-31, Method: Compositional matrix adjust.\n"+
" Identities = 58/86 (67%), Positives = 72/86 (84%), Gaps = 0/86 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            +K++  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+ +EKRPFVEEA\n"+
"Sbjct  59   AKSESRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKAWKALSLAEKRPFVEEA  118\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            ERLRVQH +DHP+YKY+PRRRK VK \n"+
"Sbjct  119  ERLRVQHMQDHPNYKYRPRRRKQVKR  144\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_001636205.1<a name=XP_001636205></a> predicted protein [Nematostella vectensis]\n"+
" EDO44142.1<a name=EDO44142></a> predicted protein [Nematostella vectensis]  \n"+
"Length=349\n"+
"\n"+
" Score = 130 bits (328),  Expect = 5e-31, Method: Compositional matrix adjust.\n"+
" Identities = 59/103 (57%), Positives = 74/103 (72%), Gaps = 0/103 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"             +KRPMNAFMVWAQ  RR+LAD  P LHNAELSK LG  WR LN ++KRPFV+EAERLR+\n"+
"Sbjct  72   RIKRPMNAFMVWAQVERRRLADANPELHNAELSKMLGLTWRALNSTQKRPFVDEAERLRL  131\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKA  206\n"+
"            QH +D+P+YKY+PRRRK  K     +  A   + ++  A  K+\n"+
"Sbjct  132  QHMQDYPNYKYRPRRRKHSKRAAKRSTGAAAGSKVNGTACQKS  174\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_001368625.1<a name=XP_001368625></a> PREDICTED: transcription factor SOX-17-like [Monodelphis domestica] \n"+
" \n"+
"Length=406\n"+
"\n"+
" Score = 132 bits (331),  Expect = 6e-31, Method: Compositional matrix adjust.\n"+
" Identities = 59/91 (65%), Positives = 73/91 (80%), Gaps = 0/91 (0%)\n"+
"\n"+
"Query  93   VRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKR  152\n"+
"            V  +G  K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+ +EKR\n"+
"Sbjct  63   VGASGRGKGESRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALSLAEKR  122\n"+
"\n"+
"Query  153  PFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            PFVEEAERLRVQH +D+P+YKY+PRRRK VK\n"+
"Sbjct  123  PFVEEAERLRVQHMQDYPNYKYRPRRRKQVK  153\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013908416.1<a name=XP_013908416></a> PREDICTED: transcription factor SOX-17 [Thamnophis sirtalis] \n"+
" \n"+
"Length=385\n"+
"\n"+
" Score = 131 bits (329),  Expect = 6e-31, Method: Compositional matrix adjust.\n"+
" Identities = 58/89 (65%), Positives = 71/89 (80%), Gaps = 0/89 (0%)\n"+
"\n"+
"Query  95   VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"             +G +K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LG+ WR L + EKRPF\n"+
"Sbjct  55   ASGRAKGETRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGQSWRALTQEEKRPF  114\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            VEEAERLR+QH +DHP YKY+PRRRK VK\n"+
"Sbjct  115  VEEAERLRLQHMRDHPHYKYRPRRRKQVK  143\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_571362.2<a name=NP_571362></a> SRY-box 17 [Danio rerio]\n"+
" AAH86959.1<a name=AAH86959></a> SRY-box containing gene 17 [Danio rerio]  \n"+
"Length=413\n"+
"\n"+
" Score = 131 bits (330),  Expect = 8e-31, Method: Compositional matrix adjust.\n"+
" Identities = 58/90 (64%), Positives = 72/90 (80%), Gaps = 0/90 (0%)\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            G  K++P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L   +KRPFVE\n"+
"Sbjct  55   GRGKSEPRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALPMVDKRPFVE  114\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRKSVKNGQ  186\n"+
"            EAERLRV+H +DHP+YKY+PRRRK VK  +\n"+
"Sbjct  115  EAERLRVKHMQDHPNYKYRPRRRKQVKRNK  144\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015770640.1<a name=XP_015770640></a> PREDICTED: transcription factor Sox-11-like [Acropora digitifera]\n"+
" ACF33141.1<a name=ACF33141></a> SoxC [Acropora millepora]  \n"+
"Length=292\n"+
"\n"+
" Score = 128 bits (322),  Expect = 1e-30, Method: Compositional matrix adjust.\n"+
" Identities = 58/92 (63%), Positives = 77/92 (84%), Gaps = 3/92 (3%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K+  HVKRPMNAFMVW+Q  RRK+A+++P +HNAE+SK LGK W+LL+ESEKRPFVEE+E\n"+
"Sbjct  30   KSMQHVKRPMNAFMVWSQIERRKMAEEHPDMHNAEISKRLGKRWKLLSESEKRPFVEESE  89\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRRK---SVKNGQAE  188\n"+
"            RLR++H + +PDYKY+PR++K     KNG A+\n"+
"Sbjct  90   RLRIRHMQAYPDYKYRPRKKKQPAKQKNGGAQ  121\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">Q6F2F0.2<a name=Q6F2F0></a> RecName: Full=Transcription factor Sox-17-beta.3; AltName: Full=SRY \n"+
"(sex determining region Y)-box 17-beta.3\n"+
" OCA32199.1<a name=OCA32199></a> hypothetical protein XENTR_v90016802mg [Xenopus tropicalis]  \n"+
"\n"+
"Length=376\n"+
"\n"+
" Score = 130 bits (327),  Expect = 1e-30, Method: Compositional matrix adjust.\n"+
" Identities = 59/95 (62%), Positives = 72/95 (76%), Gaps = 0/95 (0%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"            N   K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L  + KRPFV\n"+
"Sbjct  49   NSRGKAEARIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKSLTLASKRPFV  108\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAE  190\n"+
"            EEAERLRVQH +D+PDYKY+PRR+K VK  + E E\n"+
"Sbjct  109  EEAERLRVQHIQDYPDYKYRPRRKKQVKRMKREEE  143\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007889185.1<a name=XP_007889185></a> PREDICTED: transcription factor SOX-17 [Callorhinchus milii] \n"+
" \n"+
"Length=414\n"+
"\n"+
" Score = 131 bits (329),  Expect = 1e-30, Method: Compositional matrix adjust.\n"+
" Identities = 57/87 (66%), Positives = 72/87 (83%), Gaps = 0/87 (0%)\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            G +K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK WR L+ +EKRPFVE\n"+
"Sbjct  63   GRAKAEARIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWRGLSIAEKRPFVE  122\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            EAERLR+QH ++HP+YKY+PRRRK +K\n"+
"Sbjct  123  EAERLRIQHMQEHPNYKYRPRRRKQIK  149\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006633984.1<a name=XP_006633984></a> PREDICTED: transcription factor SOX-17 [Lepisosteus oculatus] \n"+
" \n"+
"Length=391\n"+
"\n"+
" Score = 130 bits (327),  Expect = 1e-30, Method: Compositional matrix adjust.\n"+
" Identities = 59/84 (70%), Positives = 70/84 (83%), Gaps = 0/84 (0%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K +P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L  +EKRPFVEEAE\n"+
"Sbjct  60   KAEPRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALPMAEKRPFVEEAE  119\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            RLRVQH +DHP+YKY+PRRRK VK\n"+
"Sbjct  120  RLRVQHMQDHPNYKYRPRRRKQVK  143\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007231138.1<a name=XP_007231138></a> PREDICTED: transcription factor Sox-17-alpha-A [Astyanax mexicanus] \n"+
" \n"+
"Length=428\n"+
"\n"+
" Score = 131 bits (329),  Expect = 2e-30, Method: Compositional matrix adjust.\n"+
" Identities = 57/85 (67%), Positives = 71/85 (84%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            ++ +P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+  +KRPFVEEA\n"+
"Sbjct  40   ARTEPRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALSMVDKRPFVEEA  99\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ERLRVQH +DHP+YKY+PRRRK VK\n"+
"Sbjct  100  ERLRVQHMQDHPNYKYRPRRRKQVK  124\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KPP57227.1<a name=KPP57227></a> transcription factor Sox-17-alpha-like [Scleropages formosus] \n"+
" \n"+
"Length=404\n"+
"\n"+
" Score = 130 bits (327),  Expect = 2e-30, Method: Compositional matrix adjust.\n"+
" Identities = 58/85 (68%), Positives = 72/85 (85%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            ++++P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L  +EKRPFVEEA\n"+
"Sbjct  65   ARSEPRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALPVAEKRPFVEEA  124\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ERLRVQH +DHP+YKY+PRRRK VK\n"+
"Sbjct  125  ERLRVQHMQDHPNYKYRPRRRKQVK  149\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_003224366.1<a name=XP_003224366></a> PREDICTED: transcription factor SOX-17 [Anolis carolinensis] \n"+
" \n"+
"Length=371\n"+
"\n"+
" Score = 129 bits (325),  Expect = 2e-30, Method: Compositional matrix adjust.\n"+
" Identities = 59/90 (66%), Positives = 71/90 (79%), Gaps = 0/90 (0%)\n"+
"\n"+
"Query  95   VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"            V G +K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LG+ WR L+  EKRPF\n"+
"Sbjct  63   VPGRAKGEARIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGQSWRALSPEEKRPF  122\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            VEEAERLR+QH +DHP YKY+PRRRK VK \n"+
"Sbjct  123  VEEAERLRLQHMRDHPHYKYRPRRRKQVKR  152\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACX50287.1<a name=ACX50287></a> SRY-box containing protein 17, partial [Eleutherodactylus coqui] \n"+
" \n"+
"Length=307\n"+
"\n"+
" Score = 128 bits (321),  Expect = 2e-30, Method: Compositional matrix adjust.\n"+
" Identities = 59/88 (67%), Positives = 70/88 (80%), Gaps = 0/88 (0%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"            N  +K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L   EKRPFV\n"+
"Sbjct  16   NPRNKAEARIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKTWKSLTLPEKRPFV  75\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            EEAERLRVQH +DHP+YKY+PRRRK VK\n"+
"Sbjct  76   EEAERLRVQHMQDHPNYKYRPRRRKQVK  103\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006624184.1<a name=XP_006624184></a> PREDICTED: transcription factor Sox-8-like [Apis dorsata]  \n"+
"Length=157\n"+
"\n"+
" Score = 123 bits (309),  Expect = 2e-30, Method: Compositional matrix adjust.\n"+
" Identities = 56/78 (72%), Positives = 65/78 (83%), Gaps = 1/78 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV++VL+GYDWTLVP+  + +G  K   HVKRPMNAFMVWAQAARR LADQYP LHN\n"+
"Sbjct  68   ISAAVTKVLQGYDWTLVPVATKGSGD-KRAAHVKRPMNAFMVWAQAARRILADQYPQLHN  126\n"+
"\n"+
"Query  133  AELSKTLGKLWRLLNESE  150\n"+
"            AELSKTLGKLWRLL++ +\n"+
"Sbjct  127  AELSKTLGKLWRLLSDDD  144\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015519572.1<a name=XP_015519572></a> PREDICTED: SOX domain-containing protein dichaete-like [Neodiprion \n"+
"lecontei]  \n"+
"Length=210\n"+
"\n"+
" Score = 124 bits (312),  Expect = 3e-30, Method: Compositional matrix adjust.\n"+
" Identities = 54/99 (55%), Positives = 82/99 (83%), Gaps = 5/99 (5%)\n"+
"\n"+
"Query  91   MPVRVNGSS---KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLN  147\n"+
"            M  +V+ S    ++K HVKRPMNAFMVW++  RRK+A+++P +HN+E+SK LG  W++L+\n"+
"Sbjct  21   MEAKVSSSCTTEESKEHVKRPMNAFMVWSRLQRRKIAEKHPKMHNSEISKRLGAEWKVLS  80\n"+
"\n"+
"Query  148  ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRK--SVKN  184\n"+
"            +++KRPF++EA+RLR+QH +DHP+YKY+PRR++  SVKN\n"+
"Sbjct  81   DADKRPFIDEAKRLRIQHMRDHPNYKYRPRRKQKTSVKN  119\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012262763.1<a name=XP_012262763></a> PREDICTED: transcription factor SOX-14-like [Athalia rosae]  \n"+
"\n"+
"Length=248\n"+
"\n"+
" Score = 125 bits (315),  Expect = 3e-30, Method: Compositional matrix adjust.\n"+
" Identities = 50/88 (57%), Positives = 74/88 (84%), Gaps = 0/88 (0%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"            N  S  + HVKRPMNAFMVW++  R+K+A++YP +HN+E+SK LG  W++L+E EKRPF+\n"+
"Sbjct  48   NCDSTKELHVKRPMNAFMVWSRLQRKKIAEKYPKMHNSEISKRLGAEWKILSEQEKRPFI  107\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            +EA+RLR+QH +DHP+YKY+PRR++ ++\n"+
"Sbjct  108  DEAKRLRIQHMRDHPNYKYRPRRKQKIQ  135\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KPI97312.1<a name=KPI97312></a> Transcription factor SOX-9 [Papilio xuthus]  \n"+
"Length=177\n"+
"\n"+
" Score = 123 bits (309),  Expect = 4e-30, Method: Compositional matrix adjust.\n"+
" Identities = 56/77 (73%), Positives = 69/77 (90%), Gaps = 0/77 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMV+AQA RR+L++Q P LHNAELSK+LG +W+ L+E +K PFV+EAE+LR \n"+
"Sbjct  5    HVKRPMNAFMVFAQAMRRRLSEQRPSLHNAELSKSLGSMWKSLSEEQKLPFVKEAEKLRT  64\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRK  180\n"+
"            QHKK++PDYKYQPRRRK\n"+
"Sbjct  65   QHKKEYPDYKYQPRRRK  81\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACF06316.1<a name=ACF06316></a> Sox9, partial [Oncorhynchus mykiss]\n"+
" ACF06317.1<a name=ACF06317></a> Sox9, partial [Oncorhynchus mykiss]  \n"+
"Length=58\n"+
"\n"+
" Score = 119 bits (297),  Expect = 5e-30, Method: Compositional matrix adjust.\n"+
" Identities = 55/58 (95%), Positives = 56/58 (97%), Gaps = 0/58 (0%)\n"+
"\n"+
"Query  129  HLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQ  186\n"+
"            HLHNAELSKTLGKLWRLLNE EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS+KN Q\n"+
"Sbjct  1    HLHNAELSKTLGKLWRLLNEGEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSMKNAQ  58\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KNC25060.1<a name=KNC25060></a> hypothetical protein FF38_11817, partial [Lucilia cuprina]  \n"+
"Length=676\n"+
"\n"+
" Score = 132 bits (332),  Expect = 6e-30, Method: Compositional matrix adjust.\n"+
" Identities = 55/83 (66%), Positives = 72/83 (87%), Gaps = 0/83 (0%)\n"+
"\n"+
"Query  98   SSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEE  157\n"+
"            S + K H+KRPMNAFMVWAQAARR ++ Q+PHL N+ELSK+LGKLW+ L +S+K+PF++ \n"+
"Sbjct  3    SDRKKEHIKRPMNAFMVWAQAARRVMSQQHPHLQNSELSKSLGKLWKNLKDSDKQPFMDV  62\n"+
"\n"+
"Query  158  AERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            AE+LR  HK++HPDYKYQPRR+K\n"+
"Sbjct  63   AEKLRKTHKQEHPDYKYQPRRKK  85\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017327721.1<a name=XP_017327721></a> PREDICTED: transcription factor Sox-17-alpha-like [Ictalurus \n"+
"punctatus]  \n"+
"Length=442\n"+
"\n"+
" Score = 129 bits (325),  Expect = 7e-30, Method: Compositional matrix adjust.\n"+
" Identities = 57/84 (68%), Positives = 69/84 (82%), Gaps = 0/84 (0%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+  +KRPFVEEAE\n"+
"Sbjct  55   KGEARIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALSMLDKRPFVEEAE  114\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            RLRVQH +DHP+YKY+PRRRK VK\n"+
"Sbjct  115  RLRVQHMQDHPNYKYRPRRRKQVK  138\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KPP65607.1<a name=KPP65607></a> transcription factor Sox-7-like [Scleropages formosus]  \n"+
"Length=368\n"+
"\n"+
" Score = 128 bits (321),  Expect = 7e-30, Method: Compositional matrix adjust.\n"+
" Identities = 55/92 (60%), Positives = 72/92 (78%), Gaps = 0/92 (0%)\n"+
"\n"+
"Query  92   PVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEK  151\n"+
"            P+R     + +P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L   +K\n"+
"Sbjct  33   PIRAQEERRAEPRIRRPMNAFMVWAKDERKRLAVQNPDLHNAELSKMLGKSWKALTTLQK  92\n"+
"\n"+
"Query  152  RPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            RP+VEEAERLRVQH +D+P+YKY+PRR+K +K\n"+
"Sbjct  93   RPYVEEAERLRVQHMQDYPNYKYRPRRKKQIK  124\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014211339.1<a name=XP_014211339></a> PREDICTED: transcription factor SOX-9-like [Copidosoma floridanum] \n"+
" \n"+
"Length=378\n"+
"\n"+
" Score = 128 bits (321),  Expect = 9e-30, Method: Compositional matrix adjust.\n"+
" Identities = 56/72 (78%), Positives = 68/72 (94%), Gaps = 0/72 (0%)\n"+
"\n"+
"Query  109  MNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKD  168\n"+
"            MNAFMVWAQAAR+KLA+Q+P LHNAELSKTLGKLW+ L++S+K+PFVEE++RLRV HK+ \n"+
"Sbjct  1    MNAFMVWAQAARKKLAEQHPQLHNAELSKTLGKLWKQLSDSDKKPFVEESDRLRVIHKRT  60\n"+
"\n"+
"Query  169  HPDYKYQPRRRK  180\n"+
"            HPDYKYQPRR+K\n"+
"Sbjct  61   HPDYKYQPRRKK  72\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006030602.1<a name=XP_006030602></a> PREDICTED: transcription factor SOX-12 [Alligator sinensis]  \n"+
"\n"+
"Length=216\n"+
"\n"+
" Score = 123 bits (309),  Expect = 1e-29, Method: Compositional matrix adjust.\n"+
" Identities = 53/85 (62%), Positives = 70/85 (82%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ DQ+P +HNAE+SK LG+ W+LL +SEK PFV+EAERLR+\n"+
"Sbjct  41   HIKRPMNAFMVWSQHERRKIMDQWPDMHNAEISKRLGRRWQLLQDSEKIPFVKEAERLRL  100\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAE  188\n"+
"            +H  D+PDYKY+PR++  V  G+A \n"+
"Sbjct  101  KHMADYPDYKYRPRKKGKVGAGKAR  125\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013863771.1<a name=XP_013863771></a> PREDICTED: transcription factor SOX-17 [Austrofundulus limnaeus] \n"+
" \n"+
"Length=395\n"+
"\n"+
" Score = 128 bits (321),  Expect = 1e-29, Method: Compositional matrix adjust.\n"+
" Identities = 58/84 (69%), Positives = 70/84 (83%), Gaps = 0/84 (0%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K++P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L   EK+PFVEEAE\n"+
"Sbjct  60   KSEPRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALPVPEKQPFVEEAE  119\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            RLRVQH +DHP+YKY+PRRRK VK\n"+
"Sbjct  120  RLRVQHMQDHPNYKYRPRRRKQVK  143\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007902655.1<a name=XP_007902655></a> PREDICTED: transcription factor Sox-7-like [Callorhinchus milii] \n"+
" \n"+
"Length=360\n"+
"\n"+
" Score = 127 bits (319),  Expect = 1e-29, Method: Compositional matrix adjust.\n"+
" Identities = 56/85 (66%), Positives = 71/85 (84%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            +K +P ++RPMNAFMVWA+  R+KLA Q P LHNAELSK LG+ W+ L  ++KRPFVEEA\n"+
"Sbjct  35   NKTEPRIRRPMNAFMVWAKDERKKLAIQNPDLHNAELSKMLGRSWKALAPAQKRPFVEEA  94\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ERLRVQH +DHP+YKY+PRR+K +K\n"+
"Sbjct  95   ERLRVQHMQDHPNYKYRPRRKKQIK  119\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EJW85535.1<a name=EJW85535></a> hypothetical protein WUBG_03553, partial [Wuchereria bancrofti] \n"+
" \n"+
"Length=170\n"+
"\n"+
" Score = 121 bits (304),  Expect = 1e-29, Method: Compositional matrix adjust.\n"+
" Identities = 50/79 (63%), Positives = 67/79 (85%), Gaps = 0/79 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"             VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG+ W+LLNESEKRPF++EA+RLR \n"+
"Sbjct  84   RVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGQEWKLLNESEKRPFIDEAKRLRA  143\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSV  182\n"+
"             H K+HPDYKY+PRR++ +\n"+
"Sbjct  144  IHMKEHPDYKYRPRRKRKI  162\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015781109.1<a name=XP_015781109></a> PREDICTED: putative uncharacterized protein DDB_G0277255 [Tetranychus \n"+
"urticae]  \n"+
"Length=1031\n"+
"\n"+
" Score = 131 bits (330),  Expect = 2e-29, Method: Compositional matrix adjust.\n"+
" Identities = 55/79 (70%), Positives = 68/79 (86%), Gaps = 0/79 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            ++RPMNAFMVWA+A R++LAD+ P LHNA+LSK LGK WR L   E+RPFVEEAERLRVQ\n"+
"Sbjct  230  IRRPMNAFMVWAKAERKRLADENPDLHNADLSKMLGKRWRALTLQERRPFVEEAERLRVQ  289\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRRKSVK  183\n"+
"            H +D+P+YKY+PRRRK+ K\n"+
"Sbjct  290  HMQDYPNYKYRPRRRKNGK  308\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009091490.1<a name=XP_009091490></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-12 [Serinus \n"+
"canaria]  \n"+
"Length=326\n"+
"\n"+
" Score = 126 bits (316),  Expect = 2e-29, Method: Compositional matrix adjust.\n"+
" Identities = 53/85 (62%), Positives = 69/85 (81%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ DQ+P +HNAE+SK LG+ W+LL++SEK PFV EAERLR+\n"+
"Sbjct  64   HIKRPMNAFMVWSQHERRKIMDQWPDMHNAEISKRLGRRWQLLHDSEKIPFVREAERLRL  123\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAE  188\n"+
"            +H  D+PDYKY+PR++  V  G A \n"+
"Sbjct  124  KHMADYPDYKYRPRKKGKVGTGAAR  148\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006077057.1<a name=XP_006077057></a> PREDICTED: transcription factor SOX-17 [Bubalus bubalis]  \n"+
"Length=279\n"+
"\n"+
" Score = 124 bits (312),  Expect = 2e-29, Method: Compositional matrix adjust.\n"+
" Identities = 57/85 (67%), Positives = 68/85 (80%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L  +EKRPFVEEAE\n"+
"Sbjct  63   KGESRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALTLAEKRPFVEEAE  122\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRRKSVKN  184\n"+
"            RLRVQH +DHP+YK +PRRRK VK \n"+
"Sbjct  123  RLRVQHMQDHPNYKSRPRRRKQVKR  147\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017779068.1<a name=XP_017779068></a> PREDICTED: SOX domain-containing protein dichaete-like [Nicrophorus \n"+
"vespilloides]  \n"+
"Length=149\n"+
"\n"+
" Score = 120 bits (301),  Expect = 2e-29, Method: Compositional matrix adjust.\n"+
" Identities = 53/99 (54%), Positives = 71/99 (72%), Gaps = 0/99 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            +KRPMNAFMVW++  R++++  YP LHN+E+SK LG  W+LL E EKRPF++EA+RLR Q\n"+
"Sbjct  8    IKRPMNAFMVWSRIRRKRISSDYPRLHNSEISKVLGAEWKLLTEFEKRPFIDEAKRLRNQ  67\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAI  203\n"+
"            H  DHPDYKY+PRR+  V   +   E+  E+  I  N I\n"+
"Sbjct  68   HMLDHPDYKYKPRRKPKVDKTRIPEEKVQEKAEIQNNFI  106\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_018404069.1<a name=XP_018404069></a> PREDICTED: transcription factor SOX-8-like, partial [Cyphomyrmex \n"+
"costatus]  \n"+
"Length=126\n"+
"\n"+
" Score = 119 bits (299),  Expect = 2e-29, Method: Compositional matrix adjust.\n"+
" Identities = 55/72 (76%), Positives = 61/72 (85%), Gaps = 1/72 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I  AV++VL+GYDWTLVP+  + +G  K   HVKRPMNAFMVWAQAARRKLADQYP LHN\n"+
"Sbjct  56   ISAAVAKVLQGYDWTLVPVATKGSGD-KRAAHVKRPMNAFMVWAQAARRKLADQYPQLHN  114\n"+
"\n"+
"Query  133  AELSKTLGKLWR  144\n"+
"            AELSKTLGKLWR\n"+
"Sbjct  115  AELSKTLGKLWR  126\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACZ25557.1<a name=ACZ25557></a> SRY-box containing protein B2b2, partial [Macrobrachium nipponense] \n"+
" \n"+
"Length=121\n"+
"\n"+
" Score = 119 bits (298),  Expect = 3e-29, Method: Compositional matrix adjust.\n"+
" Identities = 50/76 (66%), Positives = 65/76 (86%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL E+EKRPF++EA+RLR \n"+
"Sbjct  9    HIKRPMNAFMVWSRMQRRKIAQENPKMHNSEISKRLGAEWKLLTEAEKRPFIDEAKRLRA  68\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            QH KDHPDYKY+PRR+\n"+
"Sbjct  69   QHMKDHPDYKYRPRRK  84\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009283373.1<a name=XP_009283373></a> PREDICTED: transcription factor SOX-4 [Aptenodytes forsteri] \n"+
" \n"+
"Length=270\n"+
"\n"+
" Score = 124 bits (310),  Expect = 3e-29, Method: Compositional matrix adjust.\n"+
" Identities = 50/85 (59%), Positives = 69/85 (81%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q+P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  54   HIKRPMNAFMVWSQIERRKIMEQFPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  113\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAE  188\n"+
"            +H  D+PDYKY+PR++ +  N  A+\n"+
"Sbjct  114  KHMADYPDYKYRPRKKVNSGNSSAK  138\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ABG66955.1<a name=ABG66955></a> SOX10, partial [Ornithorhynchus anatinus]  \n"+
"Length=140\n"+
"\n"+
" Score = 119 bits (299),  Expect = 3e-29, Method: Compositional matrix adjust.\n"+
" Identities = 53/58 (91%), Positives = 56/58 (97%), Gaps = 0/58 (0%)\n"+
"\n"+
"Query  63   ESEEDKFPVCIREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAAR  120\n"+
"            E ++DKFPVCIREAVSQVL GYDWTLVPMPVRVNGSSK+KPHVKRPMNAFMVWAQAAR\n"+
"Sbjct  83   EPDDDKFPVCIREAVSQVLSGYDWTLVPMPVRVNGSSKSKPHVKRPMNAFMVWAQAAR  140\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAC26228.1<a name=BAC26228></a> unnamed protein product [Mus musculus]  \n"+
"Length=286\n"+
"\n"+
" Score = 124 bits (311),  Expect = 3e-29, Method: Compositional matrix adjust.\n"+
" Identities = 55/90 (61%), Positives = 71/90 (79%), Gaps = 2/90 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF++EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIQEAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAEEAT  193\n"+
"            +H  D+PDYKY+P  RK VK+G A A  A \n"+
"Sbjct  118  KHMADYPDYKYRP--RKKVKSGNAGAGSAA  145\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005107482.1<a name=XP_005107482></a> PREDICTED: uncharacterized protein LOC101859813 [Aplysia californica] \n"+
" \n"+
"Length=825\n"+
"\n"+
" Score = 130 bits (327),  Expect = 4e-29, Method: Compositional matrix adjust.\n"+
" Identities = 53/81 (65%), Positives = 71/81 (88%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  103  PHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLR  162\n"+
"            P ++RPMNAFMVWA+  R++LAD++P +HNAELSK LGK WR L+ S+K+PF++EAER+R\n"+
"Sbjct  72   PRIRRPMNAFMVWAKDERKRLADEHPDIHNAELSKILGKKWRSLSPSQKQPFIDEAERIR  131\n"+
"\n"+
"Query  163  VQHKKDHPDYKYQPRRRKSVK  183\n"+
"            VQH +D+PDYKY+PRRRK +K\n"+
"Sbjct  132  VQHTQDYPDYKYRPRRRKHLK  152\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KYO39461.1<a name=KYO39461></a> hypothetical protein Y1Q_0021104 [Alligator mississippiensis] \n"+
" \n"+
"Length=120\n"+
"\n"+
" Score = 119 bits (297),  Expect = 4e-29, Method: Compositional matrix adjust.\n"+
" Identities = 50/76 (66%), Positives = 66/76 (87%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW++A RRK+A + P +HN+E+SK LG  W+LL+E+EKRPF++EA+RLR \n"+
"Sbjct  7    HVKRPMNAFMVWSRAQRRKMAQENPKMHNSEISKRLGAEWKLLSEAEKRPFIDEAKRLRA  66\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  67   MHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017931822.1<a name=XP_017931822></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-17-like \n"+
"[Manacus vitellinus]  \n"+
"Length=413\n"+
"\n"+
" Score = 127 bits (318),  Expect = 4e-29, Method: Compositional matrix adjust.\n"+
" Identities = 57/83 (69%), Positives = 68/83 (82%), Gaps = 0/83 (0%)\n"+
"\n"+
"Query  95   VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"              G SK++  ++RPMNAFMVWA+  RR+LA Q P LHNAELSK LGK W+ L+ SEKRPF\n"+
"Sbjct  53   TGGRSKSEARIRRPMNAFMVWAKDERRRLAQQNPDLHNAELSKMLGKSWKALSLSEKRPF  112\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPR  177\n"+
"            VEEAERLRVQH +DHP+YKY+PR\n"+
"Sbjct  113  VEEAERLRVQHMQDHPNYKYRPR  135\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013783188.1<a name=XP_013783188></a> PREDICTED: transcription factor Sox-14-like [Limulus polyphemus] \n"+
" \n"+
"Length=271\n"+
"\n"+
" Score = 123 bits (309),  Expect = 4e-29, Method: Compositional matrix adjust.\n"+
" Identities = 61/125 (49%), Positives = 85/125 (68%), Gaps = 5/125 (4%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            S+NK H+KRPMNAFMVW++A RRK+A   P +HN+E+SK LG  W+ L+E+EKRPF++EA\n"+
"Sbjct  20   SENKDHIKRPMNAFMVWSRAQRRKIALDNPKMHNSEISKRLGADWKQLSENEKRPFIDEA  79\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQ---THISPNAIFKALQADSPHSS  215\n"+
"            +RLR QH ++HPDYKY+PRR+   +    E    +      HI P A   +  A   H++\n"+
"Sbjct  80   KRLREQHMREHPDYKYRPRRKLKTQVNNPENYPFSLSYLPEHIDPRAYIAS--ATMQHAA  137\n"+
"\n"+
"Query  216  SGMSE  220\n"+
"            +G SE\n"+
"Sbjct  138  TGYSE  142\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005240020.2<a name=XP_005240020></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-12 [Falco \n"+
"peregrinus]  \n"+
"Length=309\n"+
"\n"+
" Score = 124 bits (312),  Expect = 4e-29, Method: Compositional matrix adjust.\n"+
" Identities = 52/85 (61%), Positives = 70/85 (82%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ DQ+P +HNAE+SK LG+ W+LL++SEK PFV+EAERLR+\n"+
"Sbjct  82   HIKRPMNAFMVWSQHERRKIMDQWPDMHNAEISKRLGRRWQLLHDSEKIPFVKEAERLRL  141\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAE  188\n"+
"            +H  D+PDYKY+PR++  V  G + \n"+
"Sbjct  142  KHMADYPDYKYRPRKKGKVGTGTSR  166\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010022474.1<a name=XP_010022474></a> PREDICTED: transcription factor SOX-7-like, partial [Nestor notabilis] \n"+
" \n"+
"Length=118\n"+
"\n"+
" Score = 118 bits (296),  Expect = 4e-29, Method: Compositional matrix adjust.\n"+
" Identities = 54/87 (62%), Positives = 71/87 (82%), Gaps = 0/87 (0%)\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            G   ++  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+ S+KRP+VE\n"+
"Sbjct  4    GEKGSESRIRRPMNAFMVWAKDERKRLAVQNPDLHNAELSKMLGKSWKALSLSQKRPYVE  63\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            EAERLRV+H +D+P+YKY+PRR+K VK\n"+
"Sbjct  64   EAERLRVKHMQDYPNYKYRPRRKKQVK  90\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014712045.1<a name=XP_014712045></a> PREDICTED: transcription factor SOX-4 [Equus asinus]  \n"+
"Length=174\n"+
"\n"+
" Score = 120 bits (301),  Expect = 5e-29, Method: Compositional matrix adjust.\n"+
" Identities = 52/82 (63%), Positives = 67/82 (82%), Gaps = 2/82 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNG  185\n"+
"            +H  D+PDYKY+P  RK VK+G\n"+
"Sbjct  118  KHMADYPDYKYRP--RKKVKSG  137\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ODN03189.1<a name=ODN03189></a> Transcription factor Sox-21 [Orchesella cincta]  \n"+
"Length=227\n"+
"\n"+
" Score = 122 bits (305),  Expect = 5e-29, Method: Compositional matrix adjust.\n"+
" Identities = 52/81 (64%), Positives = 68/81 (84%), Gaps = 1/81 (1%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL E EKRPF++EA+RLR \n"+
"Sbjct  123  HIKRPMNAFMVWSRMQRRKIAQENPKMHNSEISKRLGAEWKLLTEDEKRPFIDEAKRLRA  182\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR-KSVK  183\n"+
"            QH KDHPDYKY+PRR+ K++K\n"+
"Sbjct  183  QHMKDHPDYKYRPRRKPKTLK  203\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015926892.1<a name=XP_015926892></a> PREDICTED: transcription factor SOX-4-like [Parasteatoda tepidariorum] \n"+
" \n"+
"Length=657\n"+
"\n"+
" Score = 129 bits (324),  Expect = 6e-29, Method: Compositional matrix adjust.\n"+
" Identities = 56/97 (58%), Positives = 73/97 (75%), Gaps = 0/97 (0%)\n"+
"\n"+
"Query  89   VPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNE  148\n"+
"            VP      G +  +  ++RPMNAFMVWA+  R++LAD+ P LHNA+LSK LGK WR L+ \n"+
"Sbjct  156  VPSTAGKGGRASQEQRIRRPMNAFMVWAKVERKRLADENPDLHNADLSKMLGKKWRGLSH  215\n"+
"\n"+
"Query  149  SEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNG  185\n"+
"             ++RP+VEEAERLRVQH  D+P+YKY+PRRRK+ K G\n"+
"Sbjct  216  DDRRPYVEEAERLRVQHMHDYPNYKYRPRRRKNTKRG  252\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006220173.2<a name=XP_006220173></a> PREDICTED: SRY-related protein CH31, partial [Vicugna pacos] \n"+
" \n"+
"Length=103\n"+
"\n"+
" Score = 117 bits (294),  Expect = 6e-29, Method: Compositional matrix adjust.\n"+
" Identities = 51/79 (65%), Positives = 66/79 (84%), Gaps = 0/79 (0%)\n"+
"\n"+
"Query  101  NKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAER  160\n"+
"            N+  VKRPMNAFMVW++A RRK+A + P +HN+E+SK LG  W+LL ESEKRPF++EA+R\n"+
"Sbjct  4    NQDRVKRPMNAFMVWSRAQRRKMAQENPKMHNSEISKRLGAEWKLLTESEKRPFIDEAKR  63\n"+
"\n"+
"Query  161  LRVQHKKDHPDYKYQPRRR  179\n"+
"            LR  H K+HPDYKY+PRR+\n"+
"Sbjct  64   LRAMHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ELT97997.1<a name=ELT97997></a> hypothetical protein CAPTEDRAFT_162284, partial [Capitella teleta] \n"+
" \n"+
"Length=230\n"+
"\n"+
" Score = 122 bits (305),  Expect = 6e-29, Method: Compositional matrix adjust.\n"+
" Identities = 50/76 (66%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+E EKRPF++EA+RLR \n"+
"Sbjct  44   HVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSEEEKRPFIDEAKRLRA  103\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H KDHPDYKY+PRR+\n"+
"Sbjct  104  LHMKDHPDYKYRPRRK  119\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAW34333.1<a name=AAW34333></a> SoxF [Petromyzon marinus]  \n"+
"Length=482\n"+
"\n"+
" Score = 127 bits (319),  Expect = 6e-29, Method: Compositional matrix adjust.\n"+
" Identities = 57/98 (58%), Positives = 74/98 (76%), Gaps = 0/98 (0%)\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            G  K++  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LG+ WR L+  EKRPFV+\n"+
"Sbjct  78   GKLKSESRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGRSWRSLSADEKRPFVD  137\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATE  194\n"+
"            EAERLR+QH ++HP+YKY+PRR+K  K   A+  E  E\n"+
"Sbjct  138  EAERLRIQHMQEHPNYKYRPRRKKQAKRLAAKRLEGGE  175\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005108229.1<a name=XP_005108229></a> PREDICTED: transcription factor Sox-14-like [Aplysia californica]\n"+
" XP_005108230.1<a name=XP_005108230></a> PREDICTED: transcription factor Sox-14-like [Aplysia californica] \n"+
" \n"+
"Length=332\n"+
"\n"+
" Score = 124 bits (312),  Expect = 7e-29, Method: Compositional matrix adjust.\n"+
" Identities = 53/85 (62%), Positives = 68/85 (80%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  95   VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"            VN S+ N  HVKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL E EKRPF\n"+
"Sbjct  50   VNDSASNLDHVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLTEEEKRPF  109\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            ++EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  110  IDEAKRLRALHMKEHPDYKYRPRRK  134\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012397064.1<a name=XP_012397064></a> PREDICTED: transcription factor SOX-4 [Sarcophilus harrisii] \n"+
" \n"+
"Length=348\n"+
"\n"+
" Score = 124 bits (312),  Expect = 7e-29, Method: Compositional matrix adjust.\n"+
" Identities = 52/84 (62%), Positives = 69/84 (82%), Gaps = 2/84 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQA  187\n"+
"            +H  D+PDYKY+PR++  VK+G A\n"+
"Sbjct  118  KHMADYPDYKYRPRKK--VKSGNA  139\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012588378.1<a name=XP_012588378></a> PREDICTED: transcription factor SOX-4 [Condylura cristata]  \n"+
"Length=187\n"+
"\n"+
" Score = 120 bits (301),  Expect = 8e-29, Method: Compositional matrix adjust.\n"+
" Identities = 48/76 (63%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  118  KHMADYPDYKYRPRKK  133\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_998287.1<a name=NP_998287></a> SRY (sex determining region Y)-box 4a [Danio rerio]\n"+
" AAQ72474.1<a name=AAQ72474></a> Sox4a [Danio rerio]\n"+
" AAH56564.2<a name=AAH56564></a> SRY-box containing gene 4a [Danio rerio]\n"+
" AAH65354.2<a name=AAH65354></a> SRY-box containing gene 4a [Danio rerio]  \n"+
"Length=363\n"+
"\n"+
" Score = 125 bits (313),  Expect = 8e-29, Method: Compositional matrix adjust.\n"+
" Identities = 54/98 (55%), Positives = 73/98 (74%), Gaps = 2/98 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  63   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  122\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPN  201\n"+
"            +H  D+PDYKY+PR++  VK+   +  E  E+   SP \n"+
"Sbjct  123  KHMADYPDYKYRPRKK--VKSSSGKTGEKAERVSASPG  158\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015726536.1<a name=XP_015726536></a> PREDICTED: transcription factor SOX-14 isoform X2 [Coturnix japonica] \n"+
" \n"+
"Length=189\n"+
"\n"+
" Score = 120 bits (301),  Expect = 8e-29, Method: Compositional matrix adjust.\n"+
" Identities = 50/81 (62%), Positives = 68/81 (84%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            SK   H+KRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+E+EKRP+++EA\n"+
"Sbjct  2    SKPSDHIKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSEAEKRPYIDEA  61\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRR  179\n"+
"            +RLR QH K+HPDYKY+PRR+\n"+
"Sbjct  62   KRLRAQHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007883198.1<a name=XP_007883198></a> PREDICTED: transcription factor SOX-18 [Callorhinchus milii] \n"+
" \n"+
"Length=387\n"+
"\n"+
" Score = 125 bits (314),  Expect = 9e-29, Method: Compositional matrix adjust.\n"+
" Identities = 78/183 (43%), Positives = 102/183 (56%), Gaps = 21/183 (11%)\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            G S+ +  ++RPMNAFMVWA+  R++LA Q P LHNA LSK LG+ W+ L   EKRPFVE\n"+
"Sbjct  52   GRSELESRIRRPMNAFMVWAKDERKRLALQNPDLHNAVLSKMLGQAWKSLPTDEKRPFVE  111\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRKSVKN-----GQAEAEEATEQTHISPNAIFKALQADS  211\n"+
"            EAERLRVQH  DHP+YKY+PRR+K  K      G   A     Q+H S      AL+   \n"+
"Sbjct  112  EAERLRVQHLHDHPNYKYRPRRKKQSKKIKRIEGNLLAHHGLSQSHGS------ALR---  162\n"+
"\n"+
"Query  212  PHSSSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFR  271\n"+
"             +S +  +E  +   H G+ Q    P      D+    +DL+  G P PE     P++  \n"+
"Sbjct  163  -NSPAICAESFALNAHEGRHQ---LPALARYHDLHVMGSDLESYGLPTPE---MSPLEVL  215\n"+
"\n"+
"Query  272  DVD  274\n"+
"            D D\n"+
"Sbjct  216  DTD  218\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009906066.1<a name=XP_009906066></a> PREDICTED: transcription factor SOX-7 [Picoides pubescens]  \n"+
"Length=386\n"+
"\n"+
" Score = 125 bits (314),  Expect = 9e-29, Method: Compositional matrix adjust.\n"+
" Identities = 64/141 (45%), Positives = 87/141 (62%), Gaps = 9/141 (6%)\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            G   ++  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L+ S+KRP+VE\n"+
"Sbjct  45   GEKSSESRIRRPMNAFMVWAKDERKRLAVQNPDLHNAELSKMLGKSWKALSLSQKRPYVE  104\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSS  216\n"+
"            EAERLRV+H +D+P+YKY+PRR+K VK              + P  +  +L  D      \n"+
"Sbjct  105  EAERLRVKHMQDYPNYKYRPRRKKQVKR---------ICKRVDPGFLLGSLARDQNTVPE  155\n"+
"\n"+
"Query  217  GMSEVHSPGEHSGQSQGPPTP  237\n"+
"              +   + GE  GQ + PP P\n"+
"Sbjct  156  KRTCGRAGGEKEGQGEYPPHP  176\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KRT84656.1<a name=KRT84656></a> hypothetical protein AMK59_1879, partial [Oryctes borbonicus] \n"+
" \n"+
"Length=133\n"+
"\n"+
" Score = 118 bits (295),  Expect = 1e-28, Method: Compositional matrix adjust.\n"+
" Identities = 52/72 (72%), Positives = 60/72 (83%), Gaps = 1/72 (1%)\n"+
"\n"+
"Query  73   IREAVSQVLKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHN  132\n"+
"            I EAV++VL+GYDWT  P+  +   S K K HVKRPMNAFMVWAQAARR+LADQ+P LHN\n"+
"Sbjct  63   INEAVTKVLQGYDWTFAPLATKA-SSEKKKLHVKRPMNAFMVWAQAARRRLADQHPQLHN  121\n"+
"\n"+
"Query  133  AELSKTLGKLWR  144\n"+
"            AELSK+LGKLWR\n"+
"Sbjct  122  AELSKSLGKLWR  133\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015279104.1<a name=XP_015279104></a> PREDICTED: transcription factor SOX-12 [Gekko japonicus]  \n"+
"Length=291\n"+
"\n"+
" Score = 123 bits (308),  Expect = 1e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/81 (63%), Positives = 68/81 (84%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ DQ+P +HNAE+SK LG+ W+LL +SEK PFV+EAERLR+\n"+
"Sbjct  42   HIKRPMNAFMVWSQNERRKIMDQWPDMHNAEISKRLGRRWQLLQDSEKIPFVKEAERLRL  101\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKN  184\n"+
"            +H  D+PDYKY+PR++  + N\n"+
"Sbjct  102  KHMADYPDYKYRPRKKGKMGN  122\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006003042.1<a name=XP_006003042></a> PREDICTED: transcription factor SOX-7 [Latimeria chalumnae]  \n"+
"\n"+
"Length=369\n"+
"\n"+
" Score = 124 bits (312),  Expect = 1e-28, Method: Compositional matrix adjust.\n"+
" Identities = 71/180 (39%), Positives = 95/180 (53%), Gaps = 11/180 (6%)\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            G   ++  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L  S+KRP+VE\n"+
"Sbjct  34   GEKGSETRIRRPMNAFMVWAKDERKRLAVQNPDLHNAELSKMLGKSWKALTPSQKRPYVE  93\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQAD--SPHS  214\n"+
"            EAERLRVQH +D+P+YKY+PRR+K +K              + P+ +   L  D  S   \n"+
"Sbjct  94   EAERLRVQHMQDYPNYKYRPRRKKQIKRICKR---------VDPSFLLSNLHHDQNSAAE  144\n"+
"\n"+
"Query  215  SSGMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPEGGRQPPIDFRDVD  274\n"+
"            +          E SG S GP         + Q   ++       LP      P+D  D D\n"+
"Sbjct  145  TRNCRSALEKEEDSGYSSGPSLSAIRSYRETQAANSNFDTYPYGLPTPPEMSPLDVIDPD  204\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012975545.1<a name=XP_012975545></a> PREDICTED: transcription factor SOX-21 [Mesocricetus auratus] \n"+
" \n"+
"Length=158\n"+
"\n"+
" Score = 119 bits (297),  Expect = 1e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/76 (67%), Positives = 65/76 (86%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW++A RRK+A + P +HN+E+SK LG  W+LL ESEKRPF++EA+RLR \n"+
"Sbjct  7    HVKRPMNAFMVWSRAQRRKMAQENPKMHNSEISKRLGAEWKLLTESEKRPFIDEAKRLRA  66\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  67   MHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011579667.1<a name=XP_011579667></a> PREDICTED: transcription factor SOX-4 [Aquila chrysaetos canadensis] \n"+
" \n"+
"Length=311\n"+
"\n"+
" Score = 123 bits (308),  Expect = 1e-28, Method: Compositional matrix adjust.\n"+
" Identities = 52/87 (60%), Positives = 71/87 (82%), Gaps = 2/87 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAE  190\n"+
"            +H  D+PDYKY+PR++  VK+G + A+\n"+
"Sbjct  118  KHMADYPDYKYRPRKK--VKSGNSSAK  142\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_016403489.1<a name=XP_016403489></a> PREDICTED: transcription factor Sox-7-like, partial [Sinocyclocheilus \n"+
"rhinocerous]  \n"+
"Length=160\n"+
"\n"+
" Score = 119 bits (297),  Expect = 1e-28, Method: Compositional matrix adjust.\n"+
" Identities = 55/101 (54%), Positives = 74/101 (73%), Gaps = 0/101 (0%)\n"+
"\n"+
"Query  101  NKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAER  160\n"+
"            ++P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L   +KRP+VEEAER\n"+
"Sbjct  39   SEPRIRRPMNAFMVWAKDERKRLAVQNPDLHNAELSKMLGKTWKALTPPQKRPYVEEAER  98\n"+
"\n"+
"Query  161  LRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPN  201\n"+
"            LRVQH +D+P+YKY+PRR+K +K      +     T + P+\n"+
"Sbjct  99   LRVQHMQDYPNYKYRPRRKKQLKRICKRVDPGFLLTTLGPD  139\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014021031.1<a name=XP_014021031></a> PREDICTED: transcription factor Sox-21-B-like [Salmo salar]\n"+
" XP_014021032.1<a name=XP_014021032></a> PREDICTED: transcription factor Sox-21-B-like [Salmo salar]  \n"+
"\n"+
"Length=241\n"+
"\n"+
" Score = 121 bits (303),  Expect = 1e-28, Method: Compositional matrix adjust.\n"+
" Identities = 53/81 (65%), Positives = 67/81 (83%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            SK   HVKRPMNAFMVW++A RRK+A + P +HN+E+SK LG  W+LL ESEKRPF++EA\n"+
"Sbjct  2    SKPMDHVKRPMNAFMVWSRAQRRKMAQENPKMHNSEISKRLGAEWKLLTESEKRPFIDEA  61\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRR  179\n"+
"            +RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  62   KRLRAMHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015220505.1<a name=XP_015220505></a> PREDICTED: transcription factor SOX-18 [Lepisosteus oculatus] \n"+
" \n"+
"Length=414\n"+
"\n"+
" Score = 125 bits (314),  Expect = 1e-28, Method: Compositional matrix adjust.\n"+
" Identities = 69/165 (42%), Positives = 94/165 (57%), Gaps = 15/165 (9%)\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            G S  +  ++RPMNAFMVWA+  R++LA Q P LHNA LSK LG+ W+ L+  EKRPFVE\n"+
"Sbjct  72   GKSGAESRIRRPMNAFMVWAKDERKRLAQQNPDLHNAVLSKMLGQSWKALSTVEKRPFVE  131\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSS  216\n"+
"            EAERLR+QH +DHP+YKY+PRR+K          +A +   + P+ +   L       + \n"+
"Sbjct  132  EAERLRLQHLQDHPNYKYRPRRKK----------QAKKIKRMEPSLLLHGLSQTCGGENY  181\n"+
"\n"+
"Query  217  GMSEVHSPGEHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPE  261\n"+
"             M+  H  G  SG  Q    PP     D+    ++ +  G P PE\n"+
"Sbjct  182  SMN--HQNGSQSGHHQ---LPPLNHFRDLHSVGSEFESYGLPTPE  221\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014249991.1<a name=XP_014249991></a> PREDICTED: SOX domain-containing protein dichaete-like [Cimex \n"+
"lectularius]  \n"+
"Length=254\n"+
"\n"+
" Score = 121 bits (304),  Expect = 1e-28, Method: Compositional matrix adjust.\n"+
" Identities = 53/99 (54%), Positives = 74/99 (75%), Gaps = 1/99 (1%)\n"+
"\n"+
"Query  81   LKGYDWTLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLG  140\n"+
"            + G+ ++  P+P  +   S  + H+KRPMNAFMVW++  RRK+A   P +HN+E+SK LG\n"+
"Sbjct  1    MSGHGYSF-PLPGGLEPQSPGEQHIKRPMNAFMVWSRIQRRKIALDNPKMHNSEISKRLG  59\n"+
"\n"+
"Query  141  KLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"              W+LL ESEKRPF++EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  60   AEWKLLTESEKRPFIDEAKRLRAMHMKEHPDYKYRPRRK  98\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010789329.1<a name=XP_010789329></a> PREDICTED: transcription factor Sox-11-A-like [Notothenia coriiceps] \n"+
" \n"+
"Length=305\n"+
"\n"+
" Score = 123 bits (308),  Expect = 1e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/76 (67%), Positives = 63/76 (83%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+ DQ P LHNAE+SK LGK W+LL +SEK PF+ EAERLR+\n"+
"Sbjct  55   HIKRPMNAFMVWSKIERRKIMDQSPDLHNAEISKRLGKRWKLLRDSEKIPFIREAERLRL  114\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            QH   HPDYKY+PR++\n"+
"Sbjct  115  QHMAQHPDYKYRPRKK  130\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ALC04236.1<a name=ALC04236></a> sex determining region Y-box 2 [Eisenia fetida]  \n"+
"Length=380\n"+
"\n"+
" Score = 124 bits (312),  Expect = 1e-28, Method: Compositional matrix adjust.\n"+
" Identities = 54/87 (62%), Positives = 71/87 (82%), Gaps = 3/87 (3%)\n"+
"\n"+
"Query  96   NGSSKNKP---HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKR  152\n"+
"            NG++K KP    VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+ESEKR\n"+
"Sbjct  92   NGNTKQKPVDDRVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAQWKLLSESEKR  151\n"+
"\n"+
"Query  153  PFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            PF++EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  152  PFIDEAKRLRAIHLKEHPDYKYRPRRK  178\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">CAY12631.1<a name=CAY12631></a> SRY-related HMG box B protein [Platynereis dumerilii]  \n"+
"Length=292\n"+
"\n"+
" Score = 122 bits (306),  Expect = 2e-28, Method: Compositional matrix adjust.\n"+
" Identities = 52/85 (61%), Positives = 68/85 (80%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  95   VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"             + +S N  HVKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+E EKRPF\n"+
"Sbjct  45   TSAASSNNDHVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSEEEKRPF  104\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            ++EA+RLR  H KDHPDYKY+PRR+\n"+
"Sbjct  105  IDEAKRLRALHMKDHPDYKYRPRRK  129\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_033264.2<a name=NP_033264></a> transcription factor SOX-4 [Mus musculus]\n"+
" Q06831.2<a name=Q06831></a> RecName: Full=Transcription factor SOX-4\n"+
" AAH52736.1<a name=AAH52736></a> SRY-box containing gene 4 [Mus musculus]\n"+
" EDL32406.1<a name=EDL32406></a> SRY-box containing gene 4 [Mus musculus]  \n"+
"Length=440\n"+
"\n"+
" Score = 125 bits (315),  Expect = 2e-28, Method: Compositional matrix adjust.\n"+
" Identities = 54/90 (60%), Positives = 72/90 (80%), Gaps = 2/90 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF++EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIQEAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAEEAT  193\n"+
"            +H  D+PDYKY+PR++  VK+G A A  A \n"+
"Sbjct  118  KHMADYPDYKYRPRKK--VKSGNAGAGSAA  145\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KPM05146.1<a name=KPM05146></a> hypothetical protein QR98_0036050 [Sarcoptes scabiei]  \n"+
"Length=501\n"+
"\n"+
" Score = 126 bits (317),  Expect = 2e-28, Method: Compositional matrix adjust.\n"+
" Identities = 55/98 (56%), Positives = 72/98 (73%), Gaps = 2/98 (2%)\n"+
"\n"+
"Query  101  NKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAER  160\n"+
"            N  H+KRPMNAFMVW+Q  RRK+  Q P +HNAE+SK LGK W+LL E+E++PF+ EAER\n"+
"Sbjct  141  NHNHIKRPMNAFMVWSQIERRKICVQQPEIHNAEISKQLGKRWKLLTETERQPFIAEAER  200\n"+
"\n"+
"Query  161  LRVQHKKDHPDYKYQPRRRKSVK--NGQAEAEEATEQT  196\n"+
"            LRV H K +PDYKY+P+++  +   NG A  E  + QT\n"+
"Sbjct  201  LRVLHLKQYPDYKYRPKKKLKMNPINGAANDELISTQT  238\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_001122329.1<a name=NP_001122329></a> HMG transcription factor SoxB2 [Ciona intestinalis]\n"+
" BAE06705.1<a name=BAE06705></a> transcription factor protein [Ciona intestinalis]  \n"+
"Length=318\n"+
"\n"+
" Score = 123 bits (308),  Expect = 2e-28, Method: Compositional matrix adjust.\n"+
" Identities = 50/76 (66%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LLNE EKRPF++EA+RLR \n"+
"Sbjct  29   HVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGASWKLLNECEKRPFIDEAKRLRA  88\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  89   LHMKEHPDYKYRPRRK  104\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_016063191.1<a name=XP_016063191></a> PREDICTED: transcription factor SOX-17 [Miniopterus natalensis] \n"+
" \n"+
"Length=230\n"+
"\n"+
" Score = 120 bits (302),  Expect = 2e-28, Method: Compositional matrix adjust.\n"+
" Identities = 54/87 (62%), Positives = 67/87 (77%), Gaps = 0/87 (0%)\n"+
"\n"+
"Query  92   PVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEK  151\n"+
"            P    G  K +  ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L  +EK\n"+
"Sbjct  55   PSGAAGRGKGESRIRRPMNAFMVWAKDERKRLAQQNPDLHNAELSKMLGKSWKALTLAEK  114\n"+
"\n"+
"Query  152  RPFVEEAERLRVQHKKDHPDYKYQPRR  178\n"+
"            RPFVEEAERLRVQH +DHP+YKY+P++\n"+
"Sbjct  115  RPFVEEAERLRVQHMQDHPNYKYRPQQ  141\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ETE59996.1<a name=ETE59996></a> Transcription factor SOX-12, partial [Ophiophagus hannah]  \n"+
"Length=320\n"+
"\n"+
" Score = 123 bits (308),  Expect = 2e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/84 (61%), Positives = 70/84 (83%), Gaps = 0/84 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ DQ+P +HNAE+SK LG+ W+LL +SEK PFV+EAERLR+\n"+
"Sbjct  43   HIKRPMNAFMVWSQNERRKIMDQWPDMHNAEISKRLGRRWQLLQDSEKIPFVKEAERLRL  102\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQA  187\n"+
"            +H  D+PDYKY+PR++  + + +A\n"+
"Sbjct  103  KHMADYPDYKYRPRKKGKLGSAKA  126\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007475557.2<a name=XP_007475557></a> PREDICTED: transcription factor SOX-18 [Monodelphis domestica] \n"+
" \n"+
"Length=430\n"+
"\n"+
" Score = 125 bits (313),  Expect = 2e-28, Method: Compositional matrix adjust.\n"+
" Identities = 73/175 (42%), Positives = 99/175 (57%), Gaps = 14/175 (8%)\n"+
"\n"+
"Query  90   PMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNES  149\n"+
"            P P R      +   ++RPMNAFMVWA+  R++LA Q P LHNA LSK LG+ W+ L  +\n"+
"Sbjct  99   PPPGRAESKQGDDSRIRRPMNAFMVWAKDERKRLAQQNPDLHNAVLSKMLGQAWKALTTA  158\n"+
"\n"+
"Query  150  EKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQA  209\n"+
"            EKRPFVEEAERLR+QH +DHP+YKY+PRR+K          +A +   + P+ +   L +\n"+
"Sbjct  159  EKRPFVEEAERLRIQHLQDHPNYKYRPRRKK----------QAKKTRRLEPSLLLHGL-S  207\n"+
"\n"+
"Query  210  DSPHSSSGMSEVHSPG---EHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPE  261\n"+
"              P+ SS  +   + G    HSG       PP     ++ P  A+L   G P PE\n"+
"Sbjct  208  QPPNGSSCGAGTGAEGFAATHSGVPGHQQPPPLNHFRELHPLGAELDNFGLPTPE  262\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_004061730.1<a name=XP_004061730></a> PREDICTED: transcription factor SOX-12, partial [Gorilla gorilla \n"+
"gorilla]  \n"+
"Length=135\n"+
"\n"+
" Score = 117 bits (293),  Expect = 2e-28, Method: Compositional matrix adjust.\n"+
" Identities = 50/76 (66%), Positives = 65/76 (86%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ DQ+P +HNAE+SK LG+ W+LL +SEK PFV EAERLR+\n"+
"Sbjct  39   HIKRPMNAFMVWSQHERRKIMDQWPDMHNAEISKRLGRRWQLLQDSEKIPFVREAERLRL  98\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  99   KHMADYPDYKYRPRKK  114\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011483138.1<a name=XP_011483138></a> PREDICTED: transcription factor SOX-4 isoform X1 [Oryzias latipes] \n"+
" \n"+
"Length=333\n"+
"\n"+
" Score = 123 bits (308),  Expect = 2e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/85 (60%), Positives = 70/85 (82%), Gaps = 2/85 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  63   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLRDSDKIPFIREAERLRL  122\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAE  188\n"+
"            +H  D+PDYKY+PR++  VK+G ++\n"+
"Sbjct  123  KHMADYPDYKYRPRKK--VKSGASK  145\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAS90948.1<a name=AAS90948></a> SRY-box 10, partial [Sus scrofa]  \n"+
"Length=113\n"+
"\n"+
" Score = 116 bits (291),  Expect = 2e-28, Method: Compositional matrix adjust.\n"+
" Identities = 65/116 (56%), Positives = 82/116 (71%), Gaps = 8/116 (7%)\n"+
"\n"+
"Query  394  RTHIKTEQLSP---SHYSEQQQHSPQQIAYSPFNLPHYSPSYPPITRSQYDYTDHQNSSS  450\n"+
"            +  +KTE   P   SHYS+Q   S  QIAY+  +LPHY  ++P I+R Q+DY+DHQ S  \n"+
"Sbjct  3    KAQVKTETAGPQGPSHYSDQP--STSQIAYTSLSLPHYGSAFPSISRPQFDYSDHQPSGP  60\n"+
"\n"+
"Query  451  YYSHAAGQGTGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQL  506\n"+
"            YY H +GQ +GLYS F+YM P+QRP+YT I+D S  PS PQ+HSP HWEQPVYT L\n"+
"Sbjct  61   YYGH-SGQTSGLYSAFSYMGPSQRPLYTAISDPS--PSGPQSHSPTHWEQPVYTTL  113\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KQL60869.1<a name=KQL60869></a> hypothetical protein AAES_04462 [Amazona aestiva]  \n"+
"Length=148\n"+
"\n"+
" Score = 117 bits (294),  Expect = 2e-28, Method: Compositional matrix adjust.\n"+
" Identities = 48/76 (63%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  14   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  73\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  74   KHMADYPDYKYRPRKK  89\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_560125.2<a name=XP_560125></a> AGAP000922-PA [Anopheles gambiae str. PEST]\n"+
" EAL41657.2<a name=EAL41657></a> AGAP000922-PA [Anopheles gambiae str. PEST]  \n"+
"Length=619\n"+
"\n"+
" Score = 127 bits (318),  Expect = 3e-28, Method: Compositional matrix adjust.\n"+
" Identities = 57/93 (61%), Positives = 73/93 (78%), Gaps = 0/93 (0%)\n"+
"\n"+
"Query  98   SSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEE  157\n"+
"            S+K K H+KRPMNAFMVWAQAARR++A Q P L N+E+SK LGK+W+ L +  K+PFVE+\n"+
"Sbjct  15   STKKKQHIKRPMNAFMVWAQAARREMAQQQPRLQNSEISKDLGKIWKSLKDEAKQPFVEQ  74\n"+
"\n"+
"Query  158  AERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAE  190\n"+
"            AE+LR+ HK  HP YKYQPRR+KS +   A A+\n"+
"Sbjct  75   AEKLRLAHKSQHPYYKYQPRRKKSKRCVGAGAK  107\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">CRZ22701.1<a name=CRZ22701></a> Bm3958, isoform a [Brugia malayi]  \n"+
"Length=373\n"+
"\n"+
" Score = 124 bits (310),  Expect = 3e-28, Method: Compositional matrix adjust.\n"+
" Identities = 56/91 (62%), Positives = 73/91 (80%), Gaps = 3/91 (3%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K    VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG+ W+LLNESEKRPF++EA+\n"+
"Sbjct  83   KGDDRVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGQEWKLLNESEKRPFIDEAK  142\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRR-KSV--KNGQA  187\n"+
"            RLR  H K+HPDYKY+PRR+ K++  KNG A\n"+
"Sbjct  143  RLRAIHMKEHPDYKYRPRRKTKNLPKKNGLA  173\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KPP76091.1<a name=KPP76091></a> transcription factor Sox-7-like [Scleropages formosus]  \n"+
"Length=388\n"+
"\n"+
" Score = 124 bits (311),  Expect = 3e-28, Method: Compositional matrix adjust.\n"+
" Identities = 71/168 (42%), Positives = 96/168 (57%), Gaps = 16/168 (10%)\n"+
"\n"+
"Query  94   RVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRP  153\n"+
"            R  G    +P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L   +KRP\n"+
"Sbjct  45   RSAGERSAEPRIRRPMNAFMVWAKDERKRLAVQNPDLHNAELSKMLGKSWKALTPPQKRP  104\n"+
"\n"+
"Query  154  FVEEAERLRVQHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPN--------AIFK  205\n"+
"            +VEEAERLRVQH +D+P+YKY+PRR+K +K      +     T ++P+           +\n"+
"Sbjct  105  YVEEAERLRVQHMQDYPNYKYRPRRKKQLKRICKRVDPGFLLTGLAPDQNALPDARGCCR  164\n"+
"\n"+
"Query  206  ALQADSPHSSS-GMSEVHS----PGEHSGQSQ---GPPTPPTTPKTDV  245\n"+
"            +L  D   S S G+  + +    PG  +G      G PTPP     D \n"+
"Sbjct  165  SLDKDDEASYSPGLPAIRTFRDAPGSGAGFDTYPYGLPTPPEMSPLDA  212\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002161752.2<a name=XP_002161752></a> PREDICTED: transcription factor SOX-18-like [Hydra vulgaris] \n"+
" \n"+
"Length=404\n"+
"\n"+
" Score = 124 bits (311),  Expect = 3e-28, Method: Compositional matrix adjust.\n"+
" Identities = 55/82 (67%), Positives = 68/82 (83%), Gaps = 1/82 (1%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            VKRPMN+FMVWAQ AR+KLA++YPHLHNA LSK LGKLW++L+  EK+P+V EA RL   \n"+
"Sbjct  87   VKRPMNSFMVWAQTARKKLAEKYPHLHNAHLSKMLGKLWKMLSPDEKQPYVLEASRLDKL  146\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRR-KSVKNG  185\n"+
"            HK +HP+YKY+PRRR K +K G\n"+
"Sbjct  147  HKDEHPEYKYRPRRRPKGLKRG  168\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAI00556.1<a name=AAI00556></a> Sox14 protein, partial [Mus musculus]  \n"+
"Length=402\n"+
"\n"+
" Score = 124 bits (311),  Expect = 3e-28, Method: Compositional matrix adjust.\n"+
" Identities = 54/92 (59%), Positives = 74/92 (80%), Gaps = 1/92 (1%)\n"+
"\n"+
"Query  89   VPMPVRVNGS-SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLN  147\n"+
"             P P R+ G+ SK   H+KRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+\n"+
"Sbjct  153  FPAPARLAGTMSKPSDHIKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLS  212\n"+
"\n"+
"Query  148  ESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            E+EKRP+++EA+RLR QH K+HPDYKY+PRR+\n"+
"Sbjct  213  EAEKRPYIDEAKRLRAQHMKEHPDYKYRPRRK  244\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006899239.1<a name=XP_006899239></a> PREDICTED: LOW QUALITY PROTEIN: protein SOX-15 [Elephantulus \n"+
"edwardii]  \n"+
"Length=236\n"+
"\n"+
" Score = 120 bits (300),  Expect = 3e-28, Method: Compositional matrix adjust.\n"+
" Identities = 62/131 (47%), Positives = 78/131 (60%), Gaps = 6/131 (5%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            VKRPMNAFMVW+ A RR++A Q P +HN+E+SK LG  W+LL E EKRPFVEEA+RLR +\n"+
"Sbjct  44   VKRPMNAFMVWSSAQRRQMAQQNPTMHNSEISKRLGAQWKLLGEDEKRPFVEEAKRLRAR  103\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRRKSVKN------GQAEAEEATEQTHISPNAIFKALQADSPHSSSGM  218\n"+
"            H +D+PDYKYQPRR+           GQ  +  A  Q    P            +   G \n"+
"Sbjct  104  HLRDYPDYKYQPRRKTKGPGPAHPHLGQGRSSVAGRQHTWQPGCATTHGTRSFGYQPPGY  163\n"+
"\n"+
"Query  219  SEVHSPGEHSG  229\n"+
"            S V+ PG + G\n"+
"Sbjct  164  STVYMPGSYWG  174\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KTF84828.1<a name=KTF84828></a> hypothetical protein cypCar_00006806 [Cyprinus carpio]  \n"+
"Length=194\n"+
"\n"+
" Score = 119 bits (297),  Expect = 3e-28, Method: Compositional matrix adjust.\n"+
" Identities = 50/83 (60%), Positives = 67/83 (81%), Gaps = 0/83 (0%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"            N SS ++  VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL ++EKRPF+\n"+
"Sbjct  26   NNSSNDQDRVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGADWKLLTDAEKRPFI  85\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRR  178\n"+
"            +EA+RLR  H K+HPDYKY+PRR\n"+
"Sbjct  86   DEAKRLRAMHMKEHPDYKYRPRR  108\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015502573.1<a name=XP_015502573></a> PREDICTED: transcription factor SOX-12 isoform X1 [Parus major] \n"+
" \n"+
"Length=533\n"+
"\n"+
" Score = 125 bits (315),  Expect = 4e-28, Method: Compositional matrix adjust.\n"+
" Identities = 53/85 (62%), Positives = 69/85 (81%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ DQ+P +HNAE+SK LG+ W+LL++SEK PFV EAERLR+\n"+
"Sbjct  37   HIKRPMNAFMVWSQHERRKIMDQWPDMHNAEISKRLGRRWQLLHDSEKIPFVREAERLRL  96\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAE  188\n"+
"            +H  D+PDYKY+PR++  V  G A \n"+
"Sbjct  97   KHMADYPDYKYRPRKKGKVGTGAAR  121\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">CDQ97354.1<a name=CDQ97354></a> unnamed protein product [Oncorhynchus mykiss]  \n"+
"Length=207\n"+
"\n"+
" Score = 119 bits (297),  Expect = 4e-28, Method: Compositional matrix adjust.\n"+
" Identities = 54/108 (50%), Positives = 79/108 (73%), Gaps = 4/108 (4%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +++K PF+ EAERLR+\n"+
"Sbjct  59   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDTDKIPFIREAERLRL  118\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRK---SVKNGQAE-AEEATEQTHISPNAIFKAL  207\n"+
"            +H  D+PDYKY+PR++    S K  + E  E+  +++  S +++ K L\n"+
"Sbjct  119  KHMADYPDYKYRPRKKVKTPSTKTERGERGEKGADRSGGSKSSLKKKL  166\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EHJ72187.1<a name=EHJ72187></a> Sox21b [Danaus plexippus]  \n"+
"Length=201\n"+
"\n"+
" Score = 119 bits (297),  Expect = 4e-28, Method: Compositional matrix adjust.\n"+
" Identities = 52/89 (58%), Positives = 68/89 (76%), Gaps = 4/89 (4%)\n"+
"\n"+
"Query  95   VNGSSKNKP----HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESE  150\n"+
"            +NG S  K     H+KRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+LL+E E\n"+
"Sbjct  53   MNGQSHQKKSQEEHIKRPMNAFMVWSRLQRRKIAQDNPKMHNSEISKRLGAEWKLLSEDE  112\n"+
"\n"+
"Query  151  KRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            KRPF++EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  113  KRPFIDEAKRLRAMHMKEHPDYKYRPRRK  141\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013115892.1<a name=XP_013115892></a> PREDICTED: transcription factor Sox-21-A-like [Stomoxys calcitrans]\n"+
" XP_013115893.1<a name=XP_013115893></a> PREDICTED: transcription factor Sox-21-A-like [Stomoxys calcitrans] \n"+
" \n"+
"Length=306\n"+
"\n"+
" Score = 121 bits (304),  Expect = 4e-28, Method: Compositional matrix adjust.\n"+
" Identities = 49/79 (62%), Positives = 64/79 (81%), Gaps = 0/79 (0%)\n"+
"\n"+
"Query  101  NKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAER  160\n"+
"            N  H+KRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+LL E+EKRPF++EA+R\n"+
"Sbjct  64   NNDHIKRPMNAFMVWSRGQRRKMAQDNPKMHNSEISKRLGAEWKLLTETEKRPFIDEAKR  123\n"+
"\n"+
"Query  161  LRVQHKKDHPDYKYQPRRR  179\n"+
"            LR  H K+HPDYKY+PRR+\n"+
"Sbjct  124  LRALHMKEHPDYKYRPRRK  142\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012331945.1<a name=XP_012331945></a> PREDICTED: transcription factor SOX-4 [Aotus nancymaae]  \n"+
"Length=238\n"+
"\n"+
" Score = 119 bits (299),  Expect = 4e-28, Method: Compositional matrix adjust.\n"+
" Identities = 48/76 (63%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  118  KHMADYPDYKYRPRKK  133\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011379840.1<a name=XP_011379840></a> PREDICTED: transcription factor SOX-4 [Pteropus vampyrus]  \n"+
"Length=310\n"+
"\n"+
" Score = 121 bits (304),  Expect = 4e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/82 (62%), Positives = 68/82 (83%), Gaps = 2/82 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNG  185\n"+
"            +H  D+PDYKY+PR++  VK+G\n"+
"Sbjct  118  KHMADYPDYKYRPRKK--VKSG  137\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_018121508.1<a name=XP_018121508></a> PREDICTED: transcription factor Sox-7-like [Xenopus laevis]\n"+
" OCT79104.1<a name=OCT79104></a> hypothetical protein XELAEV_18030202mg [Xenopus laevis]  \n"+
"Length=363\n"+
"\n"+
" Score = 123 bits (308),  Expect = 4e-28, Method: Compositional matrix adjust.\n"+
" Identities = 60/120 (50%), Positives = 82/120 (68%), Gaps = 13/120 (11%)\n"+
"\n"+
"Query  77   VSQVLKGYDWT--LVPMPVRVNGSSKNKPH-----------VKRPMNAFMVWAQAARRKL  123\n"+
"            ++ ++  Y WT  L   P+  + S    PH           ++RPMNAFMVWA+  R++L\n"+
"Sbjct  1    MTTLMGSYSWTESLDCSPMDGDLSDGLSPHRSPREKGSETRIRRPMNAFMVWAKDERKRL  60\n"+
"\n"+
"Query  124  ADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            A Q P LHNAELSK LGK W+ L+ ++KRP+VEEAERLRVQH +D+P+YKY+PRR+K +K\n"+
"Sbjct  61   AVQNPDLHNAELSKMLGKTWKALSPAQKRPYVEEAERLRVQHMQDYPNYKYRPRRKKQIK  120\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAH63054.1<a name=AAH63054></a> Sox21 protein, partial [Mus musculus]  \n"+
"Length=416\n"+
"\n"+
" Score = 124 bits (310),  Expect = 4e-28, Method: Compositional matrix adjust.\n"+
" Identities = 55/86 (64%), Positives = 71/86 (83%), Gaps = 2/86 (2%)\n"+
"\n"+
"Query  96   NGSSKNKP--HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRP  153\n"+
"            +G S +KP  HVKRPMNAFMVW++A RRK+A + P +HN+E+SK LG  W+LL ESEKRP\n"+
"Sbjct  148  HGDSMSKPVDHVKRPMNAFMVWSRAQRRKMAQENPKMHNSEISKRLGAEWKLLTESEKRP  207\n"+
"\n"+
"Query  154  FVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            F++EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  208  FIDEAKRLRAMHMKEHPDYKYRPRRK  233\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014294336.1<a name=XP_014294336></a> PREDICTED: transcription factor Sox-7-like [Halyomorpha halys] \n"+
" \n"+
"Length=404\n"+
"\n"+
" Score = 124 bits (310),  Expect = 4e-28, Method: Compositional matrix adjust.\n"+
" Identities = 54/85 (64%), Positives = 67/85 (79%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            S  +  ++RPMNAFMVWA+  R+KLAD+ P LHNA+LSK LGK WR L   ++RPFVEEA\n"+
"Sbjct  67   SGKEARIRRPMNAFMVWAKVERKKLADENPDLHNADLSKMLGKKWRSLTPQDRRPFVEEA  126\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            ERLRV H ++HP+YKY+PRRRK  K\n"+
"Sbjct  127  ERLRVMHMQEHPNYKYRPRRRKQTK  151\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ENN78216.1<a name=ENN78216></a> hypothetical protein YQE_05368, partial [Dendroctonus ponderosae] \n"+
" \n"+
"Length=287\n"+
"\n"+
" Score = 121 bits (303),  Expect = 4e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/83 (61%), Positives = 69/83 (83%), Gaps = 1/83 (1%)\n"+
"\n"+
"Query  98   SSKNKP-HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            + KN P H+KRPMNAFMVW+Q  RRK+ +  P +HNAE+SK LGK W+LLN+ E++PF+E\n"+
"Sbjct  2    TKKNNPNHIKRPMNAFMVWSQIERRKICEVSPDMHNAEISKNLGKRWKLLNDEERQPFIE  61\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            EAERLR  H+K++PDYKY+PR++\n"+
"Sbjct  62   EAERLRQLHQKEYPDYKYRPRKK  84\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">pir||JC4238<a name=JC4238></a> HMG-box transcription factor - mouse  \n"+
"Length=378\n"+
"\n"+
" Score = 123 bits (308),  Expect = 5e-28, Method: Compositional matrix adjust.\n"+
" Identities = 54/82 (66%), Positives = 68/82 (83%), Gaps = 0/82 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            + ++  ++RPMNAFMVWA+  R++LA Q P LHNA LSK LGK W+ LN +EKRPFVEEA\n"+
"Sbjct  73   TADELRIRRPMNAFMVWAKDERKRLAQQNPDLHNAVLSKMLGKAWKELNTAEKRPFVEEA  132\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            ERLRVQH +DHP+YKY+PRR+K\n"+
"Sbjct  133  ERLRVQHLRDHPNYKYRPRRKK  154\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EGV98757.1<a name=EGV98757></a> Transcription factor SOX-14 [Cricetulus griseus]  \n"+
"Length=110\n"+
"\n"+
" Score = 115 bits (288),  Expect = 5e-28, Method: Compositional matrix adjust.\n"+
" Identities = 48/76 (63%), Positives = 66/76 (87%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+E+EKRP+++EA+RLR \n"+
"Sbjct  7    HIKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSEAEKRPYIDEAKRLRA  66\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            QH K+HPDYKY+PRR+\n"+
"Sbjct  67   QHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012890132.1<a name=XP_012890132></a> PREDICTED: transcription factor SOX-14 [Dipodomys ordii]  \n"+
"Length=249\n"+
"\n"+
" Score = 120 bits (300),  Expect = 5e-28, Method: Compositional matrix adjust.\n"+
" Identities = 50/81 (62%), Positives = 68/81 (84%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            SK   H+KRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+E+EKRP+++EA\n"+
"Sbjct  2    SKPSDHIKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSEAEKRPYIDEA  61\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRR  179\n"+
"            +RLR QH K+HPDYKY+PRR+\n"+
"Sbjct  62   KRLRAQHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EMP33252.1<a name=EMP33252></a> Transcription factor SOX-12 [Chelonia mydas]  \n"+
"Length=334\n"+
"\n"+
" Score = 122 bits (305),  Expect = 5e-28, Method: Compositional matrix adjust.\n"+
" Identities = 50/79 (63%), Positives = 67/79 (85%), Gaps = 0/79 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ DQ+P +HNAE+SK LG+ W+LL +SEK PFV+EAERLR+\n"+
"Sbjct  48   HIKRPMNAFMVWSQNERRKIMDQWPDMHNAEISKRLGRRWQLLQDSEKIPFVKEAERLRL  107\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSV  182\n"+
"            +H  D+PDYKY+PR++  +\n"+
"Sbjct  108  KHMADYPDYKYRPRKKGKI  126\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">CAY12635.1<a name=CAY12635></a> SRY-related HMG box C protein [Platynereis dumerilii]  \n"+
"Length=250\n"+
"\n"+
" Score = 120 bits (300),  Expect = 5e-28, Method: Compositional matrix adjust.\n"+
" Identities = 57/104 (55%), Positives = 80/104 (77%), Gaps = 9/104 (9%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+++  P +HNAE+SK LGK W+LL+E +++PF+EEAERLR+\n"+
"Sbjct  49   HIKRPMNAFMVWSQIERRKISEIQPDMHNAEISKRLGKRWKLLSEVDRQPFIEEAERLRL  108\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR-KSVKNGQAEAEEATEQTHISPNAIFKA  206\n"+
"             H +++PDYKY+PR++ KS+K    EA   T QT    +A+ KA\n"+
"Sbjct  109  LHMQEYPDYKYRPRKKSKSMK----EATPPTTQT----SAVVKA  144\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KHN80026.1<a name=KHN80026></a> Transcription factor Sox-2 [Toxocara canis]  \n"+
"Length=277\n"+
"\n"+
" Score = 120 bits (301),  Expect = 5e-28, Method: Compositional matrix adjust.\n"+
" Identities = 54/89 (61%), Positives = 72/89 (81%), Gaps = 3/89 (3%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K    VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG+ W+LLNE+EKRPF++EA+\n"+
"Sbjct  56   KGDDRVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGQEWKLLNETEKRPFIDEAK  115\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRR-KSV--KNG  185\n"+
"            RLR  H K+HPDYKY+PRR+ K++  KNG\n"+
"Sbjct  116  RLRAIHMKEHPDYKYRPRRKTKNIPKKNG  144\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010955235.1<a name=XP_010955235></a> PREDICTED: transcription factor SOX-11, partial [Camelus bactrianus] \n"+
" \n"+
"Length=125\n"+
"\n"+
" Score = 115 bits (289),  Expect = 6e-28, Method: Compositional matrix adjust.\n"+
" Identities = 47/76 (62%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+ +Q P +HNAE+SK LGK W++L +SEK PF+ EAERLR+\n"+
"Sbjct  48   HIKRPMNAFMVWSKIERRKIMEQSPDMHNAEISKRLGKRWKMLKDSEKIPFIREAERLRL  107\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  108  KHMADYPDYKYRPRKK  123\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_003742894.1<a name=XP_003742894></a> PREDICTED: uncharacterized protein LOC100908412 [Metaseiulus \n"+
"occidentalis]  \n"+
"Length=410\n"+
"\n"+
" Score = 123 bits (309),  Expect = 6e-28, Method: Compositional matrix adjust.\n"+
" Identities = 53/87 (61%), Positives = 68/87 (78%), Gaps = 0/87 (0%)\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            G    +  ++RPMNAFMVWA+  R++LAD+ P LHNA+LSK LGK WR L   E+RP+VE\n"+
"Sbjct  111  GKRAQETRIRRPMNAFMVWAKVERKRLADENPDLHNADLSKMLGKKWRNLTPQERRPYVE  170\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            EAERLR+QH +D+P+YKY+PRRRK  K\n"+
"Sbjct  171  EAERLRIQHMQDYPNYKYRPRRRKQGK  197\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014281141.1<a name=XP_014281141></a> PREDICTED: transcription factor Sox-14-like [Halyomorpha halys] \n"+
" \n"+
"Length=265\n"+
"\n"+
" Score = 120 bits (300),  Expect = 6e-28, Method: Compositional matrix adjust.\n"+
" Identities = 50/85 (59%), Positives = 68/85 (80%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  95   VNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"            +    K +PH+KRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+LL+E+EKRPF\n"+
"Sbjct  38   LQNQVKREPHIKRPMNAFMVWSRLQRRKIAQDNPKMHNSEISKRLGAEWKLLSENEKRPF  97\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            ++EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  98   IDEAKRLRAMHMKEHPDYKYRPRRK  122\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_004924250.1<a name=XP_004924250></a> PREDICTED: transcription factor Sox-12-like [Bombyx mori]  \n"+
"Length=279\n"+
"\n"+
" Score = 120 bits (301),  Expect = 6e-28, Method: Compositional matrix adjust.\n"+
" Identities = 48/83 (58%), Positives = 69/83 (83%), Gaps = 1/83 (1%)\n"+
"\n"+
"Query  98   SSKNKP-HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            + KN P H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LG++W+ LN+ E++PF++\n"+
"Sbjct  41   TKKNNPNHIKRPMNAFMVWSQIERRKICEQTPDMHNAEISKNLGRVWKTLNDEERQPFID  100\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            EAERLR  H +++PDYKY+PR++\n"+
"Sbjct  101  EAERLRQLHMREYPDYKYRPRKK  123\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014420789.1<a name=XP_014420789></a> PREDICTED: transcription factor SOX-11 [Camelus ferus]  \n"+
"Length=159\n"+
"\n"+
" Score = 116 bits (291),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 47/76 (62%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+ +Q P +HNAE+SK LGK W++L +SEK PF+ EAERLR+\n"+
"Sbjct  48   HIKRPMNAFMVWSKIERRKIMEQSPDMHNAEISKRLGKRWKMLKDSEKIPFIREAERLRL  107\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  108  KHMADYPDYKYRPRKK  123\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EZA59007.1<a name=EZA59007></a> Putative transcription factor SOX-14 [Cerapachys biroi]  \n"+
"Length=369\n"+
"\n"+
" Score = 122 bits (307),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 52/84 (62%), Positives = 70/84 (83%), Gaps = 1/84 (1%)\n"+
"\n"+
"Query  98   SSKNKPH-VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            + KN P+ VKRPMNAFMVW+Q  RRK+ +  P LHNAE+SK LGKLW+LL +++K+PF+E\n"+
"Sbjct  3    TKKNNPNRVKRPMNAFMVWSQMERRKICEVQPDLHNAEISKRLGKLWKLLTDAQKQPFIE  62\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            EAERLR  H K++P+YKY+PR++K\n"+
"Sbjct  63   EAERLRQLHMKEYPNYKYRPRKKK  86\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006010839.1<a name=XP_006010839></a> PREDICTED: transcription factor SOX-18 [Latimeria chalumnae] \n"+
" \n"+
"Length=427\n"+
"\n"+
" Score = 123 bits (309),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 56/90 (62%), Positives = 70/90 (78%), Gaps = 0/90 (0%)\n"+
"\n"+
"Query  94   RVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRP  153\n"+
"            + +G S  +  ++RPMNAFMVWA+  R+KLA Q P LHNA LSK LG+ W+ L+  EKRP\n"+
"Sbjct  92   QTSGKSGAESKIRRPMNAFMVWAKDERKKLAQQNPDLHNAVLSKMLGQSWKALSALEKRP  151\n"+
"\n"+
"Query  154  FVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            FVEEAERLRVQH +DHP+YKY+PRR+K  K\n"+
"Sbjct  152  FVEEAERLRVQHLQDHPNYKYRPRRKKQAK  181\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007253714.1<a name=XP_007253714></a> PREDICTED: transcription factor SOX-14 [Astyanax mexicanus]  \n"+
"\n"+
"Length=264\n"+
"\n"+
" Score = 120 bits (300),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/81 (63%), Positives = 67/81 (83%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            SK   H+KRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL ESEKRP+++EA\n"+
"Sbjct  2    SKPVDHIKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLTESEKRPYIDEA  61\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRR  179\n"+
"            +RLR QH K+HPDYKY+PRR+\n"+
"Sbjct  62   KRLRAQHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005014806.1<a name=XP_005014806></a> PREDICTED: transcription factor SOX-4 [Anas platyrhynchos]  \n"+
"Length=207\n"+
"\n"+
" Score = 118 bits (295),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 48/76 (63%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W++L +SEK PF+ EAERLR+\n"+
"Sbjct  41   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKMLKDSEKIPFIREAERLRL  100\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  101  KHMADYPDYKYRPRKK  116\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005228762.1<a name=XP_005228762></a> PREDICTED: transcription factor SOX-1 [Falco peregrinus]  \n"+
"Length=142\n"+
"\n"+
" Score = 116 bits (290),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 48/82 (59%), Positives = 67/82 (82%), Gaps = 0/82 (0%)\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            G+  N+  VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W++++E+EKRPF++\n"+
"Sbjct  45   GNKANQDRVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKVMSEAEKRPFID  104\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRR  178\n"+
"            EA+RLR  H K+HPDYKY+PRR\n"+
"Sbjct  105  EAKRLRALHMKEHPDYKYRPRR  126\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013817477.1<a name=XP_013817477></a> PREDICTED: transcription factor SOX-4 [Apteryx australis mantelli] \n"+
" \n"+
"Length=362\n"+
"\n"+
" Score = 122 bits (306),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 53/87 (61%), Positives = 70/87 (80%), Gaps = 2/87 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  172  HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  231\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAE  190\n"+
"            +H  D+PDYKY+P  RK VK+G + A+\n"+
"Sbjct  232  KHMADYPDYKYRP--RKKVKSGNSSAK  256\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006121900.1<a name=XP_006121900></a> PREDICTED: transcription factor SOX-4 [Pelodiscus sinensis]  \n"+
"\n"+
"Length=439\n"+
"\n"+
" Score = 124 bits (310),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 52/87 (60%), Positives = 71/87 (82%), Gaps = 2/87 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAE  190\n"+
"            +H  D+PDYKY+PR++  VK+G + A+\n"+
"Sbjct  118  KHMADYPDYKYRPRKK--VKSGNSSAK  142\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KFP89102.1<a name=KFP89102></a> Transcription factor SOX-2, partial [Apaloderma vittatum]  \n"+
"Length=192\n"+
"\n"+
" Score = 117 bits (294),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/81 (63%), Positives = 67/81 (83%), Gaps = 1/81 (1%)\n"+
"\n"+
"Query  100  KNKPH-VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            KN P  VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+E+EKRPF++EA\n"+
"Sbjct  1    KNSPDGVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSEAEKRPFIDEA  60\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRR  179\n"+
"            +RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  61   KRLRALHMKEHPDYKYRPRRK  81\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009043906.1<a name=XP_009043906></a> hypothetical protein LOTGIDRAFT_102459, partial [Lottia gigantea]\n"+
" ESP05361.1<a name=ESP05361></a> hypothetical protein LOTGIDRAFT_102459, partial [Lottia gigantea] \n"+
" \n"+
"Length=120\n"+
"\n"+
" Score = 115 bits (288),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 46/76 (61%), Positives = 66/76 (87%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW+Q  RRK+++  P +HNAE+SK LG+ W+LLN+ +++PF+EEAERLR+\n"+
"Sbjct  42   HVKRPMNAFMVWSQMERRKISEVSPEMHNAEISKRLGRQWKLLNDEDRQPFIEEAERLRL  101\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H +++PDYKY+PR++\n"+
"Sbjct  102  LHLQEYPDYKYRPRKK  117\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KYO32952.1<a name=KYO32952></a> transcription factor SOX-11 [Alligator mississippiensis]  \n"+
"Length=172\n"+
"\n"+
" Score = 117 bits (292),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 47/76 (62%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+ +Q P +HNAE+SK LGK W++L +SEK PF+ EAERLR+\n"+
"Sbjct  48   HIKRPMNAFMVWSKIERRKIMEQSPDMHNAEISKRLGKRWKMLKDSEKIPFIREAERLRL  107\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  108  KHMADYPDYKYRPRKK  123\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_003738059.1<a name=XP_003738059></a> PREDICTED: uncharacterized protein LOC100908535 [Metaseiulus \n"+
"occidentalis]  \n"+
"Length=294\n"+
"\n"+
" Score = 120 bits (302),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/76 (67%), Positives = 65/76 (86%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW++A RRK+A + P +HN+E+SK LG  W+ L+ES KRPF+EEA+RLR \n"+
"Sbjct  8    HVKRPMNAFMVWSRAQRRKIALENPKMHNSEISKRLGTEWKRLSESSKRPFIEEAKRLRA  67\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            QH K+HPDYKY+PRR+\n"+
"Sbjct  68   QHMKEHPDYKYKPRRK  83\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KPJ07110.1<a name=KPJ07110></a> Transcription factor SOX-21 [Papilio machaon]  \n"+
"Length=262\n"+
"\n"+
" Score = 119 bits (299),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/91 (56%), Positives = 70/91 (77%), Gaps = 4/91 (4%)\n"+
"\n"+
"Query  93   VRVNGSSKNKP----HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNE  148\n"+
"            + +NG ++ K     H+KRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+LL+E\n"+
"Sbjct  57   IAMNGQAQQKKSQEEHIKRPMNAFMVWSRLQRRKIAQDNPKMHNSEISKRLGAEWKLLSE  116\n"+
"\n"+
"Query  149  SEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"             EKRPF++EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  117  DEKRPFIDEAKRLRAMHMKEHPDYKYRPRRK  147\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017326233.1<a name=XP_017326233></a> PREDICTED: transcription factor Sox-21-B-like [Ictalurus punctatus] \n"+
" \n"+
"Length=242\n"+
"\n"+
" Score = 119 bits (298),  Expect = 7e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/81 (63%), Positives = 68/81 (84%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            SK+  HVKRPMNAFMVW++A RR++A + P +HN+E+SK LG  W+LL +SEKRPF++EA\n"+
"Sbjct  2    SKSSDHVKRPMNAFMVWSRAQRRQMAQENPKMHNSEISKRLGAEWKLLTDSEKRPFIDEA  61\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRR  179\n"+
"            +RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  62   KRLRALHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006010601.1<a name=XP_006010601></a> PREDICTED: transcription factor SOX-4-like [Latimeria chalumnae] \n"+
" \n"+
"Length=368\n"+
"\n"+
" Score = 122 bits (306),  Expect = 8e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/94 (54%), Positives = 72/94 (77%), Gaps = 5/94 (5%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q+P +HNAE+SK LG+ W+LL + EK PF++EAERLR+\n"+
"Sbjct  51   HIKRPMNAFMVWSQIERRKIMEQWPDMHNAEISKRLGRRWKLLQDMEKIPFIKEAERLRL  110\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTH  197\n"+
"            +H  D+PDYKY+PR     K G++   + ++ TH\n"+
"Sbjct  111  KHMADYPDYKYKPR-----KKGKSGVSKTSKTTH  139\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_001624943.1<a name=XP_001624943></a> predicted protein [Nematostella vectensis]\n"+
" EDO32843.1<a name=EDO32843></a> predicted protein, partial [Nematostella vectensis]  \n"+
"Length=90\n"+
"\n"+
" Score = 114 bits (285),  Expect = 8e-28, Method: Compositional matrix adjust.\n"+
" Identities = 48/69 (70%), Positives = 62/69 (90%), Gaps = 0/69 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW+Q  RRK+A+++P +HNAE+SK LGK W+LL+ESEKRPFVEE+ERLR+\n"+
"Sbjct  22   HVKRPMNAFMVWSQIERRKMAEEHPDMHNAEISKRLGKRWKLLSESEKRPFVEESERLRI  81\n"+
"\n"+
"Query  164  QHKKDHPDY  172\n"+
"            +H + +PDY\n"+
"Sbjct  82   RHMQAYPDY  90\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ADB45218.1<a name=ADB45218></a> SOX4 HMG-box protein, partial [Carassius auratus auratus]  \n"+
"Length=123\n"+
"\n"+
" Score = 115 bits (288),  Expect = 8e-28, Method: Compositional matrix adjust.\n"+
" Identities = 47/73 (64%), Positives = 61/73 (84%), Gaps = 0/73 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  51   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  110\n"+
"\n"+
"Query  164  QHKKDHPDYKYQP  176\n"+
"            +H  D+PDYKY+P\n"+
"Sbjct  111  KHMADYPDYKYRP  123\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006013083.1<a name=XP_006013083></a> PREDICTED: transcription factor SOX-4 [Latimeria chalumnae]  \n"+
"\n"+
"Length=385\n"+
"\n"+
" Score = 122 bits (307),  Expect = 8e-28, Method: Compositional matrix adjust.\n"+
" Identities = 52/93 (56%), Positives = 73/93 (78%), Gaps = 2/93 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  57   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  116\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQT  196\n"+
"            +H  D+PDYKY+PR++  VK+G ++  E  ++ \n"+
"Sbjct  117  KHMADYPDYKYRPRKK--VKSGNSKPGEKGDKV  147\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015184037.1<a name=XP_015184037></a> PREDICTED: putative transcription factor SOX-14 [Polistes dominula] \n"+
" \n"+
"Length=284\n"+
"\n"+
" Score = 120 bits (301),  Expect = 8e-28, Method: Compositional matrix adjust.\n"+
" Identities = 52/79 (66%), Positives = 65/79 (82%), Gaps = 0/79 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            ++RPMNAFMVWA+  R+KLAD+ P LHNA+LSK LGK WR L   ++RP+VEEAERLRV \n"+
"Sbjct  175  IRRPMNAFMVWAKVERKKLADENPDLHNADLSKMLGKKWRGLTPQDRRPYVEEAERLRVI  234\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRRKSVK  183\n"+
"            H ++HP+YKY+PRRRK  K\n"+
"Sbjct  235  HMQEHPNYKYRPRRRKHAK  253\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_016334420.1<a name=XP_016334420></a> PREDICTED: transcription factor SOX-4 [Sinocyclocheilus anshuiensis] \n"+
" \n"+
"Length=376\n"+
"\n"+
" Score = 122 bits (306),  Expect = 9e-28, Method: Compositional matrix adjust.\n"+
" Identities = 52/92 (57%), Positives = 73/92 (79%), Gaps = 2/92 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF++EAERLR+\n"+
"Sbjct  56   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIQEAERLRL  115\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQ  195\n"+
"            +H  D+PDYKY+PR++  VK+  ++  E  E+\n"+
"Sbjct  116  KHMADYPDYKYRPRKK--VKSSGSKPSEKGEK  145\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">JAS73158.1<a name=JAS73158></a> hypothetical protein g.59290, partial [Homalodisca liturata] \n"+
" \n"+
"Length=102\n"+
"\n"+
" Score = 114 bits (285),  Expect = 9e-28, Method: Compositional matrix adjust.\n"+
" Identities = 52/81 (64%), Positives = 65/81 (80%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            ++RPMNAFMVWA+  R+KLAD+ P LHNA+LSK LGK WR L   ++RP+VEEAERLRV \n"+
"Sbjct  10   IRRPMNAFMVWAKVERKKLADENPDLHNADLSKMLGKKWRSLTPQDRRPYVEEAERLRVI  69\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRRKSVKNG  185\n"+
"            H ++HP+YKY+PRRRK  K  \n"+
"Sbjct  70   HMQEHPNYKYRPRRRKHNKRA  90\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KDR12611.1<a name=KDR12611></a> SOX domain-containing protein dichaete [Zootermopsis nevadensis] \n"+
" \n"+
"Length=300\n"+
"\n"+
" Score = 120 bits (301),  Expect = 9e-28, Method: Compositional matrix adjust.\n"+
" Identities = 50/84 (60%), Positives = 65/84 (77%), Gaps = 0/84 (0%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"             G    +PH+KRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+LL E EKRPF+\n"+
"Sbjct  31   GGHPTMEPHIKRPMNAFMVWSRIQRRKIALDNPKMHNSEISKRLGAEWKLLTEMEKRPFI  90\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            +EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  91   DEAKRLRAMHMKEHPDYKYRPRRK  114\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013401063.1<a name=XP_013401063></a> PREDICTED: transcription factor SOX-14-like [Lingula anatina] \n"+
" \n"+
"Length=263\n"+
"\n"+
" Score = 119 bits (299),  Expect = 9e-28, Method: Compositional matrix adjust.\n"+
" Identities = 51/81 (63%), Positives = 67/81 (83%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            SK+  HVKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+E EKRPF++EA\n"+
"Sbjct  3    SKSPDHVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSEDEKRPFIDEA  62\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRR  179\n"+
"            +RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  63   KRLRALHMKEHPDYKYRPRRK  83\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_005235619.1<a name=XP_005235619></a> PREDICTED: transcription factor SOX-21 [Falco peregrinus]  \n"+
"Length=274\n"+
"\n"+
" Score = 120 bits (300),  Expect = 9e-28, Method: Compositional matrix adjust.\n"+
" Identities = 53/81 (65%), Positives = 67/81 (83%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            SK   HVKRPMNAFMVW++A RRK+A + P +HN+E+SK LG  W+LL ESEKRPF++EA\n"+
"Sbjct  2    SKPVDHVKRPMNAFMVWSRAQRRKMAQENPKMHNSEISKRLGAEWKLLTESEKRPFIDEA  61\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRR  179\n"+
"            +RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  62   KRLRAMHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">EFB22985.1<a name=EFB22985></a> hypothetical protein PANDA_007191, partial [Ailuropoda melanoleuca] \n"+
" \n"+
"Length=181\n"+
"\n"+
" Score = 117 bits (292),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/76 (64%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL ESEKRPF++EA+RLR \n"+
"Sbjct  2    HIKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLTESEKRPFIDEAKRLRA  61\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  62   MHMKEHPDYKYRPRRK  77\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACF33143.1<a name=ACF33143></a> SoxF [Acropora millepora]  \n"+
"Length=370\n"+
"\n"+
" Score = 122 bits (305),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 54/71 (76%), Positives = 58/71 (82%), Gaps = 0/71 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"             +KRPMNAFMVWAQ  RR+LAD  P LHNAELSK LG+ WR LN  +KRPFVEEAERLR \n"+
"Sbjct  78   RIKRPMNAFMVWAQVERRRLADANPELHNAELSKILGQAWRALNGLQKRPFVEEAERLRQ  137\n"+
"\n"+
"Query  164  QHKKDHPDYKY  174\n"+
"            QH KDHPDYKY\n"+
"Sbjct  138  QHIKDHPDYKY  148\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013775452.1<a name=XP_013775452></a> PREDICTED: transcription factor Sox-11-A-like [Limulus polyphemus] \n"+
" \n"+
"Length=340\n"+
"\n"+
" Score = 121 bits (303),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 48/76 (63%), Positives = 65/76 (86%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P LHNAE+SK LGK W+LL E E++PF++EAERLR+\n"+
"Sbjct  52   HIKRPMNAFMVWSQIERRKICEQQPDLHNAEISKQLGKRWKLLTEKERQPFIQEAERLRI  111\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H +++PDYKY+PR++\n"+
"Sbjct  112  LHLQEYPDYKYRPRKK  127\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011487508.1<a name=XP_011487508></a> PREDICTED: transcription factor SOX-1 isoform X1 [Oryzias latipes] \n"+
" \n"+
"Length=345\n"+
"\n"+
" Score = 121 bits (304),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 51/84 (61%), Positives = 69/84 (82%), Gaps = 1/84 (1%)\n"+
"\n"+
"Query  96   NGSSK-NKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"            NG SK N+  VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W++++E+EKRPF\n"+
"Sbjct  27   NGGSKANQERVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKVMSEAEKRPF  86\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRR  178\n"+
"            ++EA+RLR  H K+HPDYKY+PRR\n"+
"Sbjct  87   IDEAKRLRAMHMKEHPDYKYRPRR  110\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012297088.1<a name=XP_012297088></a> PREDICTED: transcription factor SOX-11 [Aotus nancymaae]  \n"+
"Length=214\n"+
"\n"+
" Score = 118 bits (295),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 47/76 (62%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+ +Q P +HNAE+SK LGK W++L +SEK PF+ EAERLR+\n"+
"Sbjct  48   HIKRPMNAFMVWSKIERRKIMEQSPDMHNAEISKRLGKRWKMLKDSEKIPFIREAERLRL  107\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  108  KHMADYPDYKYRPRKK  123\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009636194.1<a name=XP_009636194></a> PREDICTED: transcription factor SOX-4 [Egretta garzetta]  \n"+
"Length=396\n"+
"\n"+
" Score = 122 bits (306),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 53/87 (61%), Positives = 70/87 (80%), Gaps = 2/87 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  211  HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  270\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAE  190\n"+
"            +H  D+PDYKY+P  RK VK+G + A+\n"+
"Sbjct  271  KHMADYPDYKYRP--RKKVKSGNSSAK  295\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007487941.1<a name=XP_007487941></a> PREDICTED: transcription factor SOX-4 [Monodelphis domestica] \n"+
" \n"+
"Length=501\n"+
"\n"+
" Score = 124 bits (311),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 52/84 (62%), Positives = 69/84 (82%), Gaps = 2/84 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQA  187\n"+
"            +H  D+PDYKY+PR++  VK+G A\n"+
"Sbjct  118  KHMADYPDYKYRPRKK--VKSGNA  139\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KTG40364.1<a name=KTG40364></a> hypothetical protein cypCar_00007729 [Cyprinus carpio]  \n"+
"Length=227\n"+
"\n"+
" Score = 118 bits (295),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 48/76 (63%), Positives = 66/76 (87%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RR++A + P +HN+E+SK LG  W+LL+ESEKRP+++EA+RLR \n"+
"Sbjct  13   HIKRPMNAFMVWSRGQRRQMALENPKMHNSEISKRLGAEWKLLSESEKRPYIDEAKRLRA  72\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            QH K+HPDYKY+PRR+\n"+
"Sbjct  73   QHMKEHPDYKYRPRRK  88\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ODN05954.1<a name=ODN05954></a> Transcription factor SOX-2, partial [Orchesella cincta]  \n"+
"Length=408\n"+
"\n"+
" Score = 122 bits (307),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 50/83 (60%), Positives = 68/83 (82%), Gaps = 0/83 (0%)\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            G + N+ H+KRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL E+EKRPF++\n"+
"Sbjct  17   GPASNQDHIKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLTEAEKRPFID  76\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  77   EAKRLRALHMKEHPDYKYRPRRK  99\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002645043.1<a name=XP_002645043></a> C. briggsae CBR-SOX-2 protein [Caenorhabditis briggsae]\n"+
" CAP34601.1<a name=CAP34601></a> Protein CBR-SOX-2 [Caenorhabditis briggsae]  \n"+
"Length=286\n"+
"\n"+
" Score = 120 bits (300),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 53/89 (60%), Positives = 71/89 (80%), Gaps = 3/89 (3%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            KN   VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W++L+E +KRPF++EA+\n"+
"Sbjct  55   KNDDRVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGTEWKMLSEQDKRPFIDEAK  114\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRR-KSV--KNG  185\n"+
"            RLR  H K+HPDYKY+PRR+ KS+  KNG\n"+
"Sbjct  115  RLRAIHMKEHPDYKYRPRRKTKSINKKNG  143\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013792539.1<a name=XP_013792539></a> PREDICTED: transcription factor SOX-4-like [Limulus polyphemus] \n"+
" \n"+
"Length=338\n"+
"\n"+
" Score = 121 bits (303),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 54/98 (55%), Positives = 72/98 (73%), Gaps = 9/98 (9%)\n"+
"\n"+
"Query  91   MPVRVNGSS---------KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGK  141\n"+
"            M V VN ++         K    VKRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK\n"+
"Sbjct  30   MTVDVNSNTPYTDATQCKKVTSRVKRPMNAFMVWSQIERRKICEQQPDMHNAEISKQLGK  89\n"+
"\n"+
"Query  142  LWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"             W+LL ESE++PF++EAERLRV H +++PDYKY+PR++\n"+
"Sbjct  90   RWKLLTESERQPFIQEAERLRVLHMQEYPDYKYRPRKK  127\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_018018069.1<a name=XP_018018069></a> PREDICTED: transcription factor Sox-2-like [Hyalella azteca] \n"+
" \n"+
"Length=490\n"+
"\n"+
" Score = 124 bits (310),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 53/92 (58%), Positives = 73/92 (79%), Gaps = 1/92 (1%)\n"+
"\n"+
"Query  93   VRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKR  152\n"+
"             + +GS   + HVKRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+LL++ EKR\n"+
"Sbjct  210  TKKDGSKAAEDHVKRPMNAFMVWSRMQRRKIAHDNPKMHNSEISKRLGAQWKLLSDEEKR  269\n"+
"\n"+
"Query  153  PFVEEAERLRVQHKKDHPDYKYQPRRR-KSVK  183\n"+
"            PF++EA+R+R QH KD+PDYKY+PRR+ KS+K\n"+
"Sbjct  270  PFIDEAKRIRAQHMKDYPDYKYRPRRKPKSMK  301\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017337977.1<a name=XP_017337977></a> PREDICTED: transcription factor SOX-4-like [Ictalurus punctatus] \n"+
" \n"+
"Length=333\n"+
"\n"+
" Score = 120 bits (302),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/86 (57%), Positives = 66/86 (77%), Gaps = 0/86 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL + +K PF+ EAERLR+\n"+
"Sbjct  47   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLRDCDKIPFIREAERLRL  106\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEA  189\n"+
"            +H  D+PDYKY+PR++     G  +A\n"+
"Sbjct  107  KHMADYPDYKYRPRKKVKTSAGACKA  132\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_004384095.1<a name=XP_004384095></a> PREDICTED: transcription factor SOX-4 [Trichechus manatus latirostris] \n"+
" \n"+
"Length=328\n"+
"\n"+
" Score = 120 bits (302),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 51/82 (62%), Positives = 68/82 (83%), Gaps = 2/82 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNG  185\n"+
"            +H  D+PDYKY+PR++  VK+G\n"+
"Sbjct  118  KHMADYPDYKYRPRKK--VKSG  137\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014043998.1<a name=XP_014043998></a> PREDICTED: transcription factor Sox-1b-like, partial [Salmo salar] \n"+
" \n"+
"Length=222\n"+
"\n"+
" Score = 118 bits (295),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/83 (59%), Positives = 67/83 (81%), Gaps = 0/83 (0%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"            NG+  N+  VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+ ++E+EKRPF+\n"+
"Sbjct  29   NGNKVNQDRVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKGMSEAEKRPFI  88\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRR  178\n"+
"            +EA+RLR  H K+HPDYKY+PRR\n"+
"Sbjct  89   DEAKRLRAMHMKEHPDYKYRPRR  111\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ACU12327.1<a name=ACU12327></a> Sox9 isoform 11, partial [Crocodylus palustris]  \n"+
"Length=69\n"+
"\n"+
" Score = 112 bits (281),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 55/58 (95%), Positives = 55/58 (95%), Gaps = 1/58 (2%)\n"+
"\n"+
"Query  248  GKADLKREGRPLPEGGRQPP-IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGHP  304\n"+
"            GK DLKREGRPLPEGGRQPP IDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNG P\n"+
"Sbjct  1    GKQDLKREGRPLPEGGRQPPHIDFRDVDIGELSSDVISNIETFDVNEFDQYLPPNGTP  58\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AGL08098.1<a name=AGL08098></a> SoxB1 [Sepia officinalis]  \n"+
"Length=293\n"+
"\n"+
" Score = 120 bits (300),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/79 (62%), Positives = 66/79 (84%), Gaps = 0/79 (0%)\n"+
"\n"+
"Query  101  NKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAER  160\n"+
"            N+  VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+E+EKRPF++EA+R\n"+
"Sbjct  43   NQDRVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSEAEKRPFIDEAKR  102\n"+
"\n"+
"Query  161  LRVQHKKDHPDYKYQPRRR  179\n"+
"            LR  H K+HPDYKY+PRR+\n"+
"Sbjct  103  LRAIHMKEHPDYKYRPRRK  121\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015183522.1<a name=XP_015183522></a> PREDICTED: transcription factor SOX-11-like [Polistes dominula] \n"+
" \n"+
"Length=496\n"+
"\n"+
" Score = 124 bits (310),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 52/83 (63%), Positives = 68/83 (82%), Gaps = 1/83 (1%)\n"+
"\n"+
"Query  100  KNKP-HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            KN P H+KRPMNAFMVW+Q  RRK+ +  P +HNAE+SK LGK W+ LNES++RPF+EEA\n"+
"Sbjct  38   KNNPNHIKRPMNAFMVWSQIERRKICEVQPDMHNAEISKRLGKEWKTLNESQRRPFIEEA  97\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKS  181\n"+
"            ERLR  H K++P+YKY+PR++ S\n"+
"Sbjct  98   ERLRQLHLKEYPNYKYRPRKKTS  120\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KFM78367.1<a name=KFM78367></a> Transcription factor SOX-21, partial [Stegodyphus mimosarum] \n"+
" \n"+
"Length=329\n"+
"\n"+
" Score = 120 bits (302),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 51/76 (67%), Positives = 65/76 (86%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW++A RRK+A + P +HN+E+SK LG  W+ L+ESEKRPF+EEA+RLR \n"+
"Sbjct  15   HVKRPMNAFMVWSRAQRRKIALENPKMHNSEISKRLGTEWKHLSESEKRPFIEEAKRLRA  74\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  75   LHMKEHPDYKYKPRRK  90\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017926527.1<a name=XP_017926527></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-21 [Manacus \n"+
"vitellinus]  \n"+
"Length=291\n"+
"\n"+
" Score = 119 bits (299),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 53/81 (65%), Positives = 67/81 (83%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            SK   HVKRPMNAFMVW++A RRK+A + P +HN+E+SK LG  W+LL ESEKRPF++EA\n"+
"Sbjct  2    SKPVDHVKRPMNAFMVWSRAQRRKMAQENPKMHNSEISKRLGAEWKLLTESEKRPFIDEA  61\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRR  179\n"+
"            +RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  62   KRLRAMHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007902519.1<a name=XP_007902519></a> PREDICTED: transcription factor SOX-11-like [Callorhinchus milii] \n"+
" \n"+
"Length=343\n"+
"\n"+
" Score = 121 bits (303),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 51/106 (48%), Positives = 73/106 (69%), Gaps = 0/106 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  R+K+ +Q P +HNAE+SK LGK W++L E+EK PF+ EAERLR+\n"+
"Sbjct  60   HIKRPMNAFMVWSQIERKKIMEQVPDMHNAEISKRLGKKWKMLKETEKTPFIREAERLRL  119\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQA  209\n"+
"            +H  D+PDYKY+PR++    +G  E     +   +      +AL+ \n"+
"Sbjct  120  KHMADYPDYKYRPRKKLRSDSGAEEKSCKKDSKMVFKKHCSRALKG  165\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012366045.1<a name=XP_012366045></a> PREDICTED: transcription factor SOX-7 [Nomascus leucogenys]  \n"+
"\n"+
"Length=222\n"+
"\n"+
" Score = 117 bits (294),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 63/134 (47%), Positives = 87/134 (65%), Gaps = 5/134 (4%)\n"+
"\n"+
"Query  109  MNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKKD  168\n"+
"            MNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L  S+KRP+V+EAERLR+QH +D\n"+
"Sbjct  1    MNAFMVWAKDERKRLAVQNPDLHNAELSKMLGKSWKALTLSQKRPYVDEAERLRLQHMQD  60\n"+
"\n"+
"Query  169  HPDYKYQPRRRKSVKNGQAEAEEATEQTHISP--NAIFKALQADSPH---SSSGMSEVHS  223\n"+
"            +P+YKY+PRR+K  K      +     + +S   NA+ +  Q  +P    +S+G SE+  \n"+
"Sbjct  61   YPNYKYRPRRKKQAKRLCKRVDPGFLLSSLSRDQNALPRVSQVQAPMLLAASAGCSELMI  120\n"+
"\n"+
"Query  224  PGEHSGQSQGPPTP  237\n"+
"             GE + +  GP  P\n"+
"Sbjct  121  QGEDARKQSGPGGP  134\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_004594843.1<a name=XP_004594843></a> PREDICTED: protein SOX-15 [Ochotona princeps]  \n"+
"Length=231\n"+
"\n"+
" Score = 118 bits (295),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 50/75 (67%), Positives = 63/75 (84%), Gaps = 0/75 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            VKRPMNAFMVW+ A RR++A Q P +HN+E+SK LG  W+LL E EKRPFVEEA+RLR +\n"+
"Sbjct  52   VKRPMNAFMVWSSAQRRQMAQQNPKMHNSEISKRLGAQWKLLGEDEKRPFVEEAKRLRAR  111\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRR  179\n"+
"            H +D+PDYKY+PRR+\n"+
"Sbjct  112  HLRDYPDYKYRPRRK  126\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KPP65045.1<a name=KPP65045></a> hypothetical protein Z043_116559 [Scleropages formosus]  \n"+
"Length=179\n"+
"\n"+
" Score = 116 bits (291),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 90/230 (39%), Positives = 122/230 (53%), Gaps = 54/230 (23%)\n"+
"\n"+
"Query  283  ISNIETFDVNEFDQYLPPNGHPGVPATHGQVTYTGSYGISSTAATPASAGH--VWMSKQQ  340\n"+
"            +SN+E FDVNEFDQYLPPNGHP    T      +GS       A  A+ GH   W+SKQQ\n"+
"Sbjct  1    MSNMEPFDVNEFDQYLPPNGHPAGMGT----AVSGSSASPYAYALAAAGGHSAAWLSKQQ  56\n"+
"\n"+
"Query  341  APPPPPQQPPQAPPAPQAPPQPQAAPPQQPAAPPQQPQAHTLTTLSSEPGQSQRTHIKTE  400\n"+
"                                       QQP++              S+P ++Q   IK+E\n"+
"Sbjct  57   ---------------------------QQPSS-------------GSDPSKAQ---IKSE  73\n"+
"\n"+
"Query  401  QLSPSHYSEQQQHSPQQIAYSPFNLPHYSPSYPPIT-RSQYDYTDHQNSSSYYSHAAGQG  459\n"+
"              S + +SE        + Y+P +LPHYS ++P +  R+Q++Y DHQ +SS Y   +   \n"+
"Sbjct  74   SASGAAFSEPSPPGGSHVTYAPLSLPHYSSAFPGLAPRAQFEYGDHQ-ASSSYYTHSSST  132\n"+
"\n"+
"Query  460  TGLYSTFTYMNPAQRPMYTPIADTSGVPSIPQTHSPQHWEQPVYTQLTRP  509\n"+
"            + LYS F+YM P+QRP+YT I D     S+PQ+HSP +WEQPVYT L+RP\n"+
"Sbjct  133  SSLYSAFSYMGPSQRPLYTAIGDPG---SVPQSHSPPNWEQPVYTTLSRP  179\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">JAT34608.1<a name=JAT34608></a> hypothetical protein g.21868, partial [Graphocephala atropunctata] \n"+
" \n"+
"Length=186\n"+
"\n"+
" Score = 116 bits (291),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/74 (66%), Positives = 63/74 (85%), Gaps = 0/74 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+ESEKRPF++EA+RLR  \n"+
"Sbjct  4    VKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSESEKRPFIDEAKRLRAV  63\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRR  178\n"+
"            H K+HPDYKY+PRR\n"+
"Sbjct  64   HMKEHPDYKYRPRR  77\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_018018080.1<a name=XP_018018080></a> PREDICTED: transcription factor Sox-14-like [Hyalella azteca] \n"+
" \n"+
"Length=373\n"+
"\n"+
" Score = 121 bits (304),  Expect = 1e-27, Method: Compositional matrix adjust.\n"+
" Identities = 54/92 (59%), Positives = 74/92 (80%), Gaps = 2/92 (2%)\n"+
"\n"+
"Query  96   NGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFV  155\n"+
"            N  +K   H+KRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+LL+E++KRPF+\n"+
"Sbjct  18   NPLTKKDDHIKRPMNAFMVWSRMQRRKIAQDNPKMHNSEISKRLGCEWKLLSETDKRPFI  77\n"+
"\n"+
"Query  156  EEAERLRVQHKKDHPDYKYQPRRR-KSV-KNG  185\n"+
"            +EA+RLR QH K+HPDYKY+PRR+ K++ KNG\n"+
"Sbjct  78   DEAKRLRAQHMKEHPDYKYRPRRKPKTLQKNG  109\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007657221.1<a name=XP_007657221></a> PREDICTED: transcription factor SOX-4 [Ornithorhynchus anatinus] \n"+
" \n"+
"Length=290\n"+
"\n"+
" Score = 119 bits (299),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 52/86 (60%), Positives = 67/86 (78%), Gaps = 2/86 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL + +K PF+ EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDGDKIPFIREAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEA  189\n"+
"            +H  D+PDYKY+P  RK VK+  A A\n"+
"Sbjct  118  KHMADYPDYKYRP--RKKVKSANANA  141\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014241837.1<a name=XP_014241837></a> PREDICTED: transcription factor SOX-2-like isoform X1 [Cimex \n"+
"lectularius]  \n"+
"Length=487\n"+
"\n"+
" Score = 123 bits (309),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 54/86 (63%), Positives = 68/86 (79%), Gaps = 0/86 (0%)\n"+
"\n"+
"Query  98   SSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEE  157\n"+
"            +S  +  ++RPMNAFMVWA+  R+KLAD+ P LHNA+LSK LGK WR L   ++RPFVEE\n"+
"Sbjct  78   ASGKEQRIRRPMNAFMVWAKVERKKLADENPDLHNADLSKMLGKKWRSLTPQDRRPFVEE  137\n"+
"\n"+
"Query  158  AERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            AERLRV H ++HP+YKY+PRRRK  K\n"+
"Sbjct  138  AERLRVMHMQEHPNYKYRPRRRKQAK  163\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_001008053.1<a name=NP_001008053></a> transcription factor Sox-11 [Xenopus tropicalis]\n"+
" Q66JF1.1<a name=Q66JF1></a> RecName: Full=Transcription factor Sox-11\n"+
" AAH80939.1<a name=AAH80939></a> SRY (sex determining region Y)-box 11 [Xenopus tropicalis]\n"+
" AAY98914.1<a name=AAY98914></a> sox11 [Xenopus tropicalis]\n"+
" OCA35733.1<a name=OCA35733></a> hypothetical protein XENTR_v90015107mg [Xenopus tropicalis]  \n"+
"\n"+
"Length=383\n"+
"\n"+
" Score = 121 bits (304),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/79 (62%), Positives = 66/79 (84%), Gaps = 0/79 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+ +Q P +HNAE+SK LGK W++LN+SEK PF+ EAERLR+\n"+
"Sbjct  47   HIKRPMNAFMVWSKIERRKIMEQSPDMHNAEISKRLGKRWKMLNDSEKIPFIREAERLRL  106\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSV  182\n"+
"            +H  D+PDYKY+PR++  V\n"+
"Sbjct  107  KHMADYPDYKYRPRKKPKV  125\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013778101.1<a name=XP_013778101></a> PREDICTED: transcription factor Sox-14-like [Limulus polyphemus] \n"+
" \n"+
"Length=327\n"+
"\n"+
" Score = 120 bits (301),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 51/82 (62%), Positives = 67/82 (82%), Gaps = 0/82 (0%)\n"+
"\n"+
"Query  98   SSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEE  157\n"+
"            SS    HVKRPMNAFMVW++A RRK+A + P +HN+E+SK LG  W+ L+E+EKRPF+EE\n"+
"Sbjct  8    SSTKDEHVKRPMNAFMVWSRAQRRKIALENPKMHNSEISKRLGAQWKNLSEAEKRPFIEE  67\n"+
"\n"+
"Query  158  AERLRVQHKKDHPDYKYQPRRR  179\n"+
"            A+RLR  H ++HPDYKY+PRR+\n"+
"Sbjct  68   AKRLRAMHMREHPDYKYKPRRK  89\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AJA38029.1<a name=AJA38029></a> sex determining region Y [Monodelphis domestica]  \n"+
"Length=212\n"+
"\n"+
" Score = 117 bits (293),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 55/110 (50%), Positives = 79/110 (72%), Gaps = 10/110 (9%)\n"+
"\n"+
"Query  87   TLVPMPVRVNGSSKNK--------PHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKT  138\n"+
"            + V   +RV+ S KN           VKRPMNAFMVW+++ RRK+A + P +HN+E+SK \n"+
"Sbjct  10   SFVEEDLRVSESVKNNWDNRSGSISRVKRPMNAFMVWSRSQRRKVAQENPKMHNSEISKL  69\n"+
"\n"+
"Query  139  LGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRRKS--VKNGQ  186\n"+
"            LG  W+LL ++EK+PF++EA+RLR +H+++HPDYKYQPRR+    +KN Q\n"+
"Sbjct  70   LGASWKLLTDNEKQPFIDEAKRLRAKHREEHPDYKYQPRRKTKSFMKNRQ  119\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KRT85334.1<a name=KRT85334></a> hypothetical protein AMK59_839 [Oryctes borbonicus]  \n"+
"Length=350\n"+
"\n"+
" Score = 120 bits (302),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 51/83 (61%), Positives = 68/83 (82%), Gaps = 1/83 (1%)\n"+
"\n"+
"Query  98   SSKNKP-HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            + KN P H+KRPMNAFMVW+Q  RRK+ +  P +HNAE+SK LGK W+LL E E++PF+E\n"+
"Sbjct  56   TKKNNPNHIKRPMNAFMVWSQIERRKICEVQPDMHNAEISKKLGKRWKLLKEEERQPFIE  115\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            EAERLR  H+K++PDYKY+PR++\n"+
"Sbjct  116  EAERLRQLHQKEYPDYKYRPRKK  138\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010620987.1<a name=XP_010620987></a> PREDICTED: transcription factor SOX-11 [Fukomys damarensis]  \n"+
"\n"+
"Length=241\n"+
"\n"+
" Score = 118 bits (295),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 47/76 (62%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+ +Q P +HNAE+SK LGK W++L +SEK PF+ EAERLR+\n"+
"Sbjct  48   HIKRPMNAFMVWSKIERRKIMEQSPDMHNAEISKRLGKRWKMLKDSEKIPFIREAERLRL  107\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  108  KHMADYPDYKYRPRKK  123\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007636191.1<a name=XP_007636191></a> PREDICTED: transcription factor SOX-4-like [Cricetulus griseus] \n"+
" \n"+
"Length=379\n"+
"\n"+
" Score = 121 bits (304),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 54/86 (63%), Positives = 70/86 (81%), Gaps = 2/86 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF++EAERLR+\n"+
"Sbjct  186  HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIQEAERLRL  245\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEA  189\n"+
"            +H  D+PDYKY+P  RK VK+G A A\n"+
"Sbjct  246  KHMADYPDYKYRP--RKKVKSGNAGA  269\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017306085.1<a name=XP_017306085></a> PREDICTED: transcription factor SOX-4-like [Ictalurus punctatus] \n"+
" \n"+
"Length=365\n"+
"\n"+
" Score = 121 bits (303),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 47/76 (62%), Positives = 66/76 (87%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q+P +HNAE+SK LGK W+LL++ +K PF++EAERLR+\n"+
"Sbjct  63   HIKRPMNAFMVWSQIERRKIMEQWPDMHNAEISKRLGKCWKLLSDYDKIPFIKEAERLRL  122\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  123  KHMADYPDYKYRPRKK  138\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">JAS27366.1<a name=JAS27366></a> hypothetical protein g.8733, partial [Clastoptera arizonana] \n"+
" \n"+
"Length=117\n"+
"\n"+
" Score = 114 bits (285),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 48/76 (63%), Positives = 62/76 (82%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+LL E EKRPF++EA+RLR \n"+
"Sbjct  41   HIKRPMNAFMVWSRIQRRKIALDNPKMHNSEISKRLGAEWKLLTEMEKRPFIDEAKRLRA  100\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  101  MHMKEHPDYKYRPRRK  116\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011908100.1<a name=XP_011908100></a> PREDICTED: protein SOX-15 isoform X1 [Cercocebus atys]  \n"+
"Length=261\n"+
"\n"+
" Score = 119 bits (297),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 50/75 (67%), Positives = 64/75 (85%), Gaps = 0/75 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            VKRPMNAFMVW+ A RR++A Q P +HN+E+SK LG  W+LL+E EKRPFVEEA+RLR +\n"+
"Sbjct  49   VKRPMNAFMVWSSAQRRQMAQQNPKMHNSEISKRLGAQWKLLDEDEKRPFVEEAKRLRAR  108\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRR  179\n"+
"            H +D+PDYKY+PRR+\n"+
"Sbjct  109  HLRDYPDYKYRPRRK  123\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012151116.1<a name=XP_012151116></a> PREDICTED: SOX domain-containing protein dichaete-like [Megachile \n"+
"rotundata]  \n"+
"Length=206\n"+
"\n"+
" Score = 117 bits (292),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/85 (58%), Positives = 68/85 (80%), Gaps = 0/85 (0%)\n"+
"\n"+
"Query  98   SSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEE  157\n"+
"            +S  + H+KRPMNAFMVW++  R+K+A   P +HN+E+SK LG  W+LL++SEKRPF++E\n"+
"Sbjct  37   ASSQEQHIKRPMNAFMVWSRIQRKKIALDNPKMHNSEISKRLGAEWKLLSDSEKRPFIDE  96\n"+
"\n"+
"Query  158  AERLRVQHKKDHPDYKYQPRRRKSV  182\n"+
"            A+RLR  H K+HPDYKY+PRR+  V\n"+
"Sbjct  97   AKRLRAMHMKEHPDYKYRPRRKPKV  121\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009859013.1<a name=XP_009859013></a> PREDICTED: HMG transcription factor SoxB2 isoform X1 [Ciona intestinalis] \n"+
" \n"+
"Length=362\n"+
"\n"+
" Score = 121 bits (303),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 50/76 (66%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LLNE EKRPF++EA+RLR \n"+
"Sbjct  29   HVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGASWKLLNECEKRPFIDEAKRLRA  88\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  89   LHMKEHPDYKYRPRRK  104\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_001266245.1<a name=NP_001266245></a> uncharacterized protein LOC100631786 [Amphimedon queenslandica]\n"+
" ACA04750.1<a name=ACA04750></a> SoxC-like [Amphimedon queenslandica]  \n"+
"Length=400\n"+
"\n"+
" Score = 122 bits (305),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 48/73 (66%), Positives = 63/73 (86%), Gaps = 0/73 (0%)\n"+
"\n"+
"Query  102  KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERL  161\n"+
"            K H+KRPMNAFMVWAQ  RRK+  ++P +HNAE+S+ LGKLWRLL++ EK+P++EE+ERL\n"+
"Sbjct  64   KEHIKRPMNAFMVWAQLERRKMTTEFPDMHNAEISRRLGKLWRLLSDREKQPYIEESERL  123\n"+
"\n"+
"Query  162  RVQHKKDHPDYKY  174\n"+
"            R+QH K +PDYKY\n"+
"Sbjct  124  RIQHMKQYPDYKY  136\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017840299.1<a name=XP_017840299></a> PREDICTED: transcription factor SOX-14 [Drosophila busckii]  \n"+
"\n"+
"Length=268\n"+
"\n"+
" Score = 119 bits (297),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/93 (53%), Positives = 68/93 (73%), Gaps = 0/93 (0%)\n"+
"\n"+
"Query  87   TLVPMPVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLL  146\n"+
"                + ++     +N+ H+KRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+LL\n"+
"Sbjct  38   VFFSLMIQNTTKRQNEEHIKRPMNAFMVWSRLQRRKIAQDNPKMHNSEISKRLGAEWKLL  97\n"+
"\n"+
"Query  147  NESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"             E EKRPF++EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  98   TEEEKRPFIDEAKRLRAMHMKEHPDYKYRPRRK  130\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007523112.1<a name=XP_007523112></a> PREDICTED: transcription factor SOX-12 [Erinaceus europaeus] \n"+
" \n"+
"Length=313\n"+
"\n"+
" Score = 120 bits (300),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 50/76 (66%), Positives = 65/76 (86%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ DQ+P +HNAE+SK LG+ W+LL +SEK PFV EAERLR+\n"+
"Sbjct  39   HIKRPMNAFMVWSQHERRKIMDQWPDMHNAEISKRLGRRWQLLQDSEKIPFVREAERLRL  98\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  99   KHMADYPDYKYRPRKK  114\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017312112.1<a name=XP_017312112></a> PREDICTED: transcription factor SOX-7 [Ictalurus punctatus]  \n"+
"\n"+
"Length=398\n"+
"\n"+
" Score = 121 bits (304),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 53/82 (65%), Positives = 68/82 (83%), Gaps = 0/82 (0%)\n"+
"\n"+
"Query  102  KPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERL  161\n"+
"            +P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L   +KRP+VEEAERL\n"+
"Sbjct  40   EPRIRRPMNAFMVWAKDERKRLAVQNPDLHNAELSKMLGKSWKALTPLQKRPYVEEAERL  99\n"+
"\n"+
"Query  162  RVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            RVQH +D+P+YKY+PRR+K +K\n"+
"Sbjct  100  RVQHMQDYPNYKYRPRRKKQLK  121\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_007901360.1<a name=XP_007901360></a> PREDICTED: transcription factor SOX-4 [Callorhinchus milii]  \n"+
"\n"+
"Length=400\n"+
"\n"+
" Score = 121 bits (304),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 53/99 (54%), Positives = 74/99 (75%), Gaps = 1/99 (1%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL + +K PF+ EAERLR+\n"+
"Sbjct  57   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDCDKIPFIREAERLRL  116\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNA  202\n"+
"            +H  D+PDYKY+P R+K+   G  +  E +E+ +  P+A\n"+
"Sbjct  117  KHMADYPDYKYRP-RKKAKSAGSNKPGEKSEKVNTKPSA  154\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">AAX43677.1<a name=AAX43677></a> SRY-box 15, partial [synthetic construct]  \n"+
"Length=234\n"+
"\n"+
" Score = 117 bits (294),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 50/75 (67%), Positives = 64/75 (85%), Gaps = 0/75 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            VKRPMNAFMVW+ A RR++A Q P +HN+E+SK LG  W+LL+E EKRPFVEEA+RLR +\n"+
"Sbjct  49   VKRPMNAFMVWSSAQRRQMAQQNPKMHNSEISKRLGAQWKLLDEDEKRPFVEEAKRLRAR  108\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRR  179\n"+
"            H +D+PDYKY+PRR+\n"+
"Sbjct  109  HLRDYPDYKYRPRRK  123\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011455662.1<a name=XP_011455662></a> PREDICTED: transcription factor Sox-2-like [Crassostrea gigas]\n"+
" EKC24855.1<a name=EKC24855></a> Transcription factor SOX-2 [Crassostrea gigas]  \n"+
"Length=327\n"+
"\n"+
" Score = 120 bits (300),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 50/82 (61%), Positives = 67/82 (82%), Gaps = 0/82 (0%)\n"+
"\n"+
"Query  98   SSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEE  157\n"+
"            S K+   VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+E+EKRPF++E\n"+
"Sbjct  70   SKKDADRVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSEAEKRPFIDE  129\n"+
"\n"+
"Query  158  AERLRVQHKKDHPDYKYQPRRR  179\n"+
"            A+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  130  AKRLRAIHMKEHPDYKYRPRRK  151\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012409093.1<a name=XP_012409093></a> PREDICTED: transcription factor SOX-12 [Sarcophilus harrisii] \n"+
" \n"+
"Length=349\n"+
"\n"+
" Score = 120 bits (302),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 50/76 (66%), Positives = 65/76 (86%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ DQ+P +HNAE+SK LG+ W+LL +SEK PFV EAERLR+\n"+
"Sbjct  45   HIKRPMNAFMVWSQHERRKIMDQWPDMHNAEISKRLGRRWQLLQDSEKIPFVREAERLRL  104\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  105  KHMADYPDYKYRPRKK  120\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014061703.1<a name=XP_014061703></a> PREDICTED: transcription factor Sox-7-like [Salmo salar]  \n"+
"Length=455\n"+
"\n"+
" Score = 122 bits (307),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 54/83 (65%), Positives = 70/83 (84%), Gaps = 0/83 (0%)\n"+
"\n"+
"Query  101  NKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAER  160\n"+
"            ++P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L  S+KRP+VEEAER\n"+
"Sbjct  39   SEPRIRRPMNAFMVWAKDERKRLAVQNPDLHNAELSKMLGKSWKALTPSQKRPYVEEAER  98\n"+
"\n"+
"Query  161  LRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            LRVQH +D+P+YKY+PRR+K +K\n"+
"Sbjct  99   LRVQHMQDYPNYKYRPRRKKQLK  121\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_018324554.1<a name=XP_018324554></a> PREDICTED: SOX domain-containing protein dichaete-like [Agrilus \n"+
"planipennis]  \n"+
"Length=228\n"+
"\n"+
" Score = 117 bits (293),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 50/83 (60%), Positives = 67/83 (81%), Gaps = 0/83 (0%)\n"+
"\n"+
"Query  97   GSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"             SS+ + H+KRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+LL+E EKRPF++\n"+
"Sbjct  18   NSSRTEEHIKRPMNAFMVWSRIQRRKIALDNPKMHNSEISKRLGAEWKLLSEVEKRPFID  77\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  78   EAKRLRALHMKEHPDYKYRPRRK  100\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015607343.1<a name=XP_015607343></a> PREDICTED: transcription factor Sox-21-B-like [Cephus cinctus] \n"+
" \n"+
"Length=338\n"+
"\n"+
" Score = 120 bits (301),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/76 (64%), Positives = 65/76 (86%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+ESEKRPF++EA+RLR \n"+
"Sbjct  11   HIKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSESEKRPFIDEAKRLRA  70\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  71   LHMKEHPDYKYRPRRK  86\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006005741.1<a name=XP_006005741></a> PREDICTED: transcription factor Sox-19a-like [Latimeria chalumnae] \n"+
" \n"+
"Length=280\n"+
"\n"+
" Score = 119 bits (297),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 55/102 (54%), Positives = 75/102 (74%), Gaps = 12/102 (12%)\n"+
"\n"+
"Query  90   PMPVRVNG-------SSKNKP-----HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSK  137\n"+
"            PMP  +NG       +SK+ P      VKRPMNAFMVW++  RRK+A + P +HN+E+SK\n"+
"Sbjct  11   PMPQSMNGGSQGANQTSKSSPPDPMDKVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISK  70\n"+
"\n"+
"Query  138  TLGKLWRLLNESEKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"             LG  W+LL+++EKRPF++EA+RLR  H KD+PDYKY+PRR+\n"+
"Sbjct  71   RLGAEWKLLSDAEKRPFIDEAKRLRAMHMKDYPDYKYRPRRK  112\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">NP_001082102.1<a name=NP_001082102></a> transcription factor Sox-18A [Xenopus laevis]\n"+
" Q90ZH8.1<a name=Q90ZH8></a> RecName: Full=Transcription factor Sox-18A; Short=xSox18alpha; \n"+
"AltName: Full=SRY (sex determining region Y)-box 18A\n"+
" BAB60829.1<a name=BAB60829></a> xSox18alpha [Xenopus laevis]\n"+
" AAI69575.1<a name=AAI69575></a> XSox18alpha protein [Xenopus laevis]\n"+
" OCT62525.1<a name=OCT62525></a> hypothetical protein XELAEV_18043608mg [Xenopus laevis]  \n"+
"Length=363\n"+
"\n"+
" Score = 120 bits (302),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 54/81 (67%), Positives = 65/81 (80%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  103  PHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLR  162\n"+
"            P ++RPMNAFMVWA+  R++LA Q P LHNA LSK LG+ W+ L   EKRPFVEEAERLR\n"+
"Sbjct  66   PRIRRPMNAFMVWAKDERKRLAQQNPDLHNAVLSKMLGQSWKNLTSVEKRPFVEEAERLR  125\n"+
"\n"+
"Query  163  VQHKKDHPDYKYQPRRRKSVK  183\n"+
"            VQH +DHP+YKY+PRR+K  K\n"+
"Sbjct  126  VQHLQDHPNYKYRPRRKKQAK  146\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015522370.1<a name=XP_015522370></a> PREDICTED: transcription factor SOX-3 [Neodiprion lecontei]  \n"+
"\n"+
"Length=297\n"+
"\n"+
" Score = 119 bits (298),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 48/76 (63%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+E EKRPF++EA+RLR \n"+
"Sbjct  10   HIKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSEGEKRPFIDEAKRLRA  69\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  70   LHMKEHPDYKYRPRRK  85\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_004605255.2<a name=XP_004605255></a> PREDICTED: protein SOX-15 [Sorex araneus]  \n"+
"Length=240\n"+
"\n"+
" Score = 117 bits (294),  Expect = 2e-27, Method: Compositional matrix adjust.\n"+
" Identities = 51/80 (64%), Positives = 63/80 (79%), Gaps = 0/80 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            VKRPMNAFMVW+ A RR++A Q P +HN+E+SK LG  W+LL E EKRPFVEEA+RLR  \n"+
"Sbjct  57   VKRPMNAFMVWSSAQRRQMAQQNPKMHNSEISKRLGAQWKLLGEDEKRPFVEEAKRLRAL  116\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRRKSVKN  184\n"+
"            H +D+PDYKY+PRR+    N\n"+
"Sbjct  117  HLRDYPDYKYRPRRKTKSSN  136\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015929247.1<a name=XP_015929247></a> PREDICTED: putative transcription factor SOX-14 [Parasteatoda \n"+
"tepidariorum]  \n"+
"Length=372\n"+
"\n"+
" Score = 120 bits (302),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 56/140 (40%), Positives = 88/140 (63%), Gaps = 3/140 (2%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K   HVKRPMNAFMVW+Q  RR++ ++ P +HNAE+SK LG +WRLL+E +++PFVEEA+\n"+
"Sbjct  49   KKSSHVKRPMNAFMVWSQIERRRICEEQPDMHNAEISKRLGMMWRLLDEDQRKPFVEEAD  108\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRRKS---VKNGQAEAEEATEQTHISPNAIFKALQADSPHSSS  216\n"+
"            RLR  H+  +PDYKY+PR++K+   VK  + ++  A  +T  +   I  +          \n"+
"Sbjct  109  RLRQLHQIQYPDYKYRPRKKKALPPVKPTKTKSNSAVNRTSAATIIIANSRHGVGKLVQR  168\n"+
"\n"+
"Query  217  GMSEVHSPGEHSGQSQGPPT  236\n"+
"            G+ ++ +  E+  + +   T\n"+
"Sbjct  169  GVKQIRNCEENRNRVKLCST  188\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002645839.1<a name=XP_002645839></a> C. briggsae CBR-SOX-3 protein [Caenorhabditis briggsae]\n"+
" CAP27551.1<a name=CAP27551></a> Protein CBR-SOX-3 [Caenorhabditis briggsae]  \n"+
"Length=213\n"+
"\n"+
" Score = 117 bits (292),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 54/120 (45%), Positives = 77/120 (64%), Gaps = 0/120 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+ L+E EKRPF++EA+RLR \n"+
"Sbjct  48   HVKRPMNAFMVWSRGQRRKMAQDNPKMHNSEISKRLGAEWKQLSEQEKRPFIDEAKRLRA  107\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHS  223\n"+
"             H K+HPDYKY+PRR+    N + +         ++P  +F    A     +  +S+ +S\n"+
"Sbjct  108  LHMKEHPDYKYRPRRKPKSANLKQQPRLNISMPTLTPPTLFNNFTAFDSLKTHDLSQYYS  167\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ETE68877.1<a name=ETE68877></a> Transcription factor SOX-4, partial [Ophiophagus hannah]  \n"+
"Length=303\n"+
"\n"+
" Score = 119 bits (298),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 48/76 (63%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  50   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  109\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  110  KHMADYPDYKYRPRKK  125\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015687179.1<a name=XP_015687179></a> PREDICTED: transcription factor SOX-4 [Protobothrops mucrosquamatus] \n"+
" \n"+
"Length=430\n"+
"\n"+
" Score = 122 bits (305),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 51/82 (62%), Positives = 68/82 (83%), Gaps = 2/82 (2%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW+Q  RRK+ +Q P +HNAE+SK LGK W+LL +S+K PF+ EAERLR+\n"+
"Sbjct  58   HIKRPMNAFMVWSQIERRKIMEQSPDMHNAEISKRLGKRWKLLKDSDKIPFIREAERLRL  117\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRKSVKNG  185\n"+
"            +H  D+PDYKY+PR++  VK+G\n"+
"Sbjct  118  KHMADYPDYKYRPRKK--VKSG  137\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_016002151.1<a name=XP_016002151></a> PREDICTED: LOW QUALITY PROTEIN: transcription factor SOX-18 [Rousettus \n"+
"aegyptiacus]  \n"+
"Length=383\n"+
"\n"+
" Score = 121 bits (303),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 52/88 (59%), Positives = 70/88 (80%), Gaps = 0/88 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            + ++  ++RPMNAFMVWA+  R++LA Q P LHNA LSK LGK W+ L+ ++KRPFVEEA\n"+
"Sbjct  77   AADESRIRRPMNAFMVWAKDERKRLAQQNPDLHNAVLSKMLGKAWKELSTADKRPFVEEA  136\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKSVKNGQ  186\n"+
"            ERLRVQH +DHP+YKY+PRR+K  +  +\n"+
"Sbjct  137  ERLRVQHLRDHPNYKYRPRRKKQARKAR  164\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014246243.1<a name=XP_014246243></a> PREDICTED: transcription factor SOX-4-like [Cimex lectularius] \n"+
" \n"+
"Length=287\n"+
"\n"+
" Score = 119 bits (297),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 51/89 (57%), Positives = 71/89 (80%), Gaps = 1/89 (1%)\n"+
"\n"+
"Query  98   SSKNKP-HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            + KN P ++KRPMNAFMVW+Q  RRKL ++ P +HNAE+SK LGK+W+ L +SE++PF+E\n"+
"Sbjct  29   TKKNNPNYIKRPMNAFMVWSQIERRKLCEKKPDMHNAEISKHLGKVWKTLKDSERQPFIE  88\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRKSVKNG  185\n"+
"            EAERLR+ H + +PDYKY+PR++    NG\n"+
"Sbjct  89   EAERLRMMHLQQYPDYKYRPRKKVIKNNG  117\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011292436.1<a name=XP_011292436></a> PREDICTED: putative transcription factor SOX-15 [Musca domestica] \n"+
" \n"+
"Length=941\n"+
"\n"+
" Score = 124 bits (312),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 56/96 (58%), Positives = 70/96 (73%), Gaps = 6/96 (6%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            ++RPMNAFMVWA+  R+KLAD+ P LHNA+LSK LGK WR L   ++RP+VEEAERLRV \n"+
"Sbjct  298  IRRPMNAFMVWAKIERKKLADENPDLHNADLSKMLGKKWRSLTPQDRRPYVEEAERLRVI  357\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRRKSVK------NGQAEAEEATE  194\n"+
"            H  +HP+YKY+PRRRK  K      NG A+ +  T \n"+
"Sbjct  358  HMTEHPNYKYRPRRRKQSKMRSLQPNGVAKEQNGTN  393\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">BAO23503.1<a name=BAO23503></a> HMG transcription factor SoxB2 [Ptychodera flava]  \n"+
"Length=246\n"+
"\n"+
" Score = 117 bits (294),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/76 (64%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+E EKRPF++EA+RLR \n"+
"Sbjct  8    HVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSEVEKRPFIDEAKRLRA  67\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  68   LHMKEHPDYKYRPRRK  83\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_015682094.1<a name=XP_015682094></a> PREDICTED: transcription factor SOX-21 [Protobothrops mucrosquamatus] \n"+
" \n"+
"Length=286\n"+
"\n"+
" Score = 119 bits (297),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 50/76 (66%), Positives = 66/76 (87%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW++A RRK+A + P +HN+E+SK LG  W+LL+E+EKRPF++EA+RLR \n"+
"Sbjct  7    HVKRPMNAFMVWSRAQRRKMAQENPKMHNSEISKRLGAEWKLLSEAEKRPFIDEAKRLRA  66\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  67   MHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_017334470.1<a name=XP_017334470></a> PREDICTED: transcription factor SOX-2 [Ictalurus punctatus]  \n"+
"\n"+
"Length=332\n"+
"\n"+
" Score = 120 bits (300),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 52/81 (64%), Positives = 67/81 (83%), Gaps = 1/81 (1%)\n"+
"\n"+
"Query  100  KNKP-HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            KN P  VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+ESEKRPF++EA\n"+
"Sbjct  31   KNSPERVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSESEKRPFIDEA  90\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRR  179\n"+
"            +RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  91   KRLRALHMKEHPDYKYRPRRK  111\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011331348.1<a name=XP_011331348></a> PREDICTED: transcription factor SOX-11-like isoform X1 [Cerapachys \n"+
"biroi]  \n"+
"Length=487\n"+
"\n"+
" Score = 122 bits (307),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 52/84 (62%), Positives = 70/84 (83%), Gaps = 1/84 (1%)\n"+
"\n"+
"Query  98   SSKNKPH-VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVE  156\n"+
"            + KN P+ VKRPMNAFMVW+Q  RRK+ +  P LHNAE+SK LGKLW+LL +++K+PF+E\n"+
"Sbjct  36   TKKNNPNRVKRPMNAFMVWSQMERRKICEVQPDLHNAEISKRLGKLWKLLTDAQKQPFIE  95\n"+
"\n"+
"Query  157  EAERLRVQHKKDHPDYKYQPRRRK  180\n"+
"            EAERLR  H K++P+YKY+PR++K\n"+
"Sbjct  96   EAERLRQLHMKEYPNYKYRPRKKK  119\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_971910.1<a name=XP_971910></a> PREDICTED: transcription factor Sox-21-A [Tribolium castaneum]\n"+
" EFA04579.1<a name=EFA04579></a> Sox21a [Tribolium castaneum]  \n"+
"Length=242\n"+
"\n"+
" Score = 117 bits (294),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/76 (64%), Positives = 65/76 (86%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+ESEKRPF++EA+RLR \n"+
"Sbjct  13   HIKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSESEKRPFIDEAKRLRA  72\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  73   LHMKEHPDYKYRPRRK  88\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009564044.1<a name=XP_009564044></a> PREDICTED: transcription factor SOX-11 [Cuculus canorus]  \n"+
"Length=236\n"+
"\n"+
" Score = 117 bits (293),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 47/76 (62%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+ +Q P +HNAE+SK LGK W++L +SEK PF+ EAERLR+\n"+
"Sbjct  48   HIKRPMNAFMVWSKIERRKIMEQSPDMHNAEISKRLGKRWKMLKDSEKIPFIREAERLRL  107\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"            +H  D+PDYKY+PR++\n"+
"Sbjct  108  KHMADYPDYKYRPRKK  123\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">ELK11050.1<a name=ELK11050></a> Transcription factor SOX-21 [Pteropus alecto]  \n"+
"Length=584\n"+
"\n"+
" Score = 124 bits (310),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 55/86 (64%), Positives = 71/86 (83%), Gaps = 2/86 (2%)\n"+
"\n"+
"Query  96   NGSSKNKP--HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRP  153\n"+
"            +G S +KP  HVKRPMNAFMVW++A RRK+A + P +HN+E+SK LG  W+LL ESEKRP\n"+
"Sbjct  305  HGESMSKPVDHVKRPMNAFMVWSRAQRRKMAQENPKMHNSEISKRLGAEWKLLTESEKRP  364\n"+
"\n"+
"Query  154  FVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            F++EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  365  FIDEAKRLRAMHMKEHPDYKYRPRRK  390\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">JAT28737.1<a name=JAT28737></a> hypothetical protein g.21869, partial [Graphocephala atropunctata] \n"+
" \n"+
"Length=192\n"+
"\n"+
" Score = 116 bits (290),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 48/75 (64%), Positives = 62/75 (83%), Gaps = 0/75 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL E EKRPF++EA+RLR  \n"+
"Sbjct  4    VKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLTEMEKRPFIDEAKRLRAM  63\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRR  179\n"+
"            H K+HPDYKY+PRR+\n"+
"Sbjct  64   HMKEHPDYKYRPRRK  78\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013201259.1<a name=XP_013201259></a> PREDICTED: transcription factor SOX-21-like [Amyelois transitella] \n"+
" \n"+
"Length=349\n"+
"\n"+
" Score = 120 bits (301),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 51/90 (57%), Positives = 67/90 (74%), Gaps = 3/90 (3%)\n"+
"\n"+
"Query  93   VRVNGSSKNKP---HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNES  149\n"+
"            + +NG    K    H+KRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+LL E \n"+
"Sbjct  37   ITMNGQQTKKSPEEHIKRPMNAFMVWSRLQRRKIAQDNPKMHNSEISKRLGAEWKLLTED  96\n"+
"\n"+
"Query  150  EKRPFVEEAERLRVQHKKDHPDYKYQPRRR  179\n"+
"            EKRPF++EA+RLR  H K+HPDYKY+PRR+\n"+
"Sbjct  97   EKRPFIDEAKRLRAMHMKEHPDYKYRPRRK  126\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014789971.1<a name=XP_014789971></a> PREDICTED: transcription factor Sox-14-like [Octopus bimaculoides]\n"+
" KOF62861.1<a name=KOF62861></a> hypothetical protein OCBIM_22021495mg [Octopus bimaculoides] \n"+
" \n"+
"Length=234\n"+
"\n"+
" Score = 117 bits (293),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/76 (64%), Positives = 64/76 (84%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+LL+E EKRPF++EA+RLR \n"+
"Sbjct  8    HVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLLSEEEKRPFIDEAKRLRA  67\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  68   LHMKEHPDYKYRPRRK  83\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_013776585.1<a name=XP_013776585></a> PREDICTED: uncharacterized protein LOC106461314 [Limulus polyphemus] \n"+
" \n"+
"Length=494\n"+
"\n"+
" Score = 122 bits (307),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 52/77 (68%), Positives = 64/77 (83%), Gaps = 0/77 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"             ++RPMNAFMVWA++ R++LAD+ P LHNA+LSK LGK WR L   E+RPFVEE+ERLRV\n"+
"Sbjct  20   RIRRPMNAFMVWAKSERKRLADENPDLHNADLSKMLGKKWRNLTPQERRPFVEESERLRV  79\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRRK  180\n"+
"            QH  D P+YKY+PRRRK\n"+
"Sbjct  80   QHMHDFPNYKYRPRRRK  96\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_002609616.1<a name=XP_002609616></a> hypothetical protein BRAFLDRAFT_125030 [Branchiostoma floridae]\n"+
" EEN65626.1<a name=EEN65626></a> hypothetical protein BRAFLDRAFT_125030 [Branchiostoma floridae] \n"+
" \n"+
"Length=668\n"+
"\n"+
" Score = 124 bits (310),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 54/76 (71%), Positives = 63/76 (83%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  108  PMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQHKK  167\n"+
"            PMNAFMVWA+  R++LA + P LHNAELSK LGK WR L  S+K+PFVEEAER+RVQH +\n"+
"Sbjct  120  PMNAFMVWARTERKRLAHEKPDLHNAELSKILGKTWRSLTTSQKQPFVEEAERIRVQHMQ  179\n"+
"\n"+
"Query  168  DHPDYKYQPRRRKSVK  183\n"+
"            DHPDYKY+PRRRK  K\n"+
"Sbjct  180  DHPDYKYRPRRRKQAK  195\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_972072.1<a name=XP_972072></a> PREDICTED: transcription factor SOX-9 isoform X1 [Tribolium castaneum]\n"+
" EFA04354.2<a name=EFA04354></a> SOX domain-containing protein dichaete-like Protein [Tribolium \n"+
"castaneum]  \n"+
"Length=207\n"+
"\n"+
" Score = 116 bits (290),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 55/124 (44%), Positives = 79/124 (64%), Gaps = 2/124 (2%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            S N  H+KRPMNAFMVW++  R+ ++  YP LHN+E+SK LG  W++L E+EKRPF++EA\n"+
"Sbjct  4    SDNSAHIKRPMNAFMVWSRIRRKHISRDYPRLHNSEISKLLGAEWKVLPEAEKRPFIDEA  63\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKSV--KNGQAEAEEATEQTHISPNAIFKALQADSPHSSS  216\n"+
"            +RLR QH  DHPDYKY+PRR+  +  K+ +   +           A +    +D  HS  \n"+
"Sbjct  64   KRLRNQHMVDHPDYKYRPRRKPKLEPKDARFFTQTVDPLQQAFTKAFYTQNVSDETHSGP  123\n"+
"\n"+
"Query  217  GMSE  220\n"+
"            G+ +\n"+
"Sbjct  124  GIGD  127\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KTG36172.1<a name=KTG36172></a> hypothetical protein cypCar_00011805 [Cyprinus carpio]  \n"+
"Length=288\n"+
"\n"+
" Score = 118 bits (296),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 52/84 (62%), Positives = 69/84 (82%), Gaps = 1/84 (1%)\n"+
"\n"+
"Query  96   NGSSK-NKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPF  154\n"+
"            NG SK N+  VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W++++ESEKRPF\n"+
"Sbjct  23   NGGSKVNQDRVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKVMSESEKRPF  82\n"+
"\n"+
"Query  155  VEEAERLRVQHKKDHPDYKYQPRR  178\n"+
"            ++EA+RLR  H K+HPDYKY+PRR\n"+
"Sbjct  83   IDEAKRLRAMHMKEHPDYKYRPRR  106\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_003220734.1<a name=XP_003220734></a> PREDICTED: transcription factor SOX-18 [Anolis carolinensis] \n"+
" \n"+
"Length=455\n"+
"\n"+
" Score = 122 bits (305),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 67/158 (42%), Positives = 95/158 (60%), Gaps = 14/158 (9%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            ++RPMNAFMVWA+  R++LA Q P LHNA LSK LG+ W+ L+ ++KRPFVEEAERLR+Q\n"+
"Sbjct  127  IRRPMNAFMVWAKDERKRLAQQNPDLHNAVLSKMLGQSWKALSANDKRPFVEEAERLRIQ  186\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRRKSVKNGQAEAEEATEQTHISPNAIFKALQADSPHSSSGMSEVHSP  224\n"+
"            H +DHP+YKY+PRR+K          +A +   + PN +   L       S GM+   + \n"+
"Sbjct  187  HLQDHPNYKYRPRRKK----------QAKKIKRMEPNILLHNLSQPCNSDSFGMNPRAAG  236\n"+
"\n"+
"Query  225  G-EHSGQSQGPPTPPTTPKTDVQPGKADLKREGRPLPE  261\n"+
"            G  H   +Q    PP     +++   +D++  G P PE\n"+
"Sbjct  237  GIGHPAHAQ---PPPLNHFRELRSVGSDMENYGLPTPE  271\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">Q7SZS1.1<a name=Q7SZS1></a> RecName: Full=Transcription factor Sox-21-A; AltName: Full=SRY-box \n"+
"containing gene 21a\n"+
" AAH56274.1<a name=AAH56274></a> SRY-box containing gene 21a [Danio rerio]\n"+
" AAH65639.1<a name=AAH65639></a> SRY-box containing gene 21a [Danio rerio]  \n"+
"Length=239\n"+
"\n"+
" Score = 117 bits (293),  Expect = 3e-27, Method: Compositional matrix adjust.\n"+
" Identities = 50/76 (66%), Positives = 65/76 (86%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            HVKRPMNAFMVW++A RRK+A   P +HN+E+SK LG  W+LL++SEKRPF++EA+RLR \n"+
"Sbjct  7    HVKRPMNAFMVWSRAQRRKMALDNPKMHNSEISKRLGGEWKLLSDSEKRPFIDEAKRLRA  66\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  67   VHMKEHPDYKYRPRRK  82\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">JAN75948.1<a name=JAN75948></a> Transcription factor Sox-7 [Daphnia magna]  \n"+
"Length=615\n"+
"\n"+
" Score = 123 bits (309),  Expect = 4e-27, Method: Compositional matrix adjust.\n"+
" Identities = 53/81 (65%), Positives = 67/81 (83%), Gaps = 0/81 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            V+RPMNAFMVWA+  R++LAD+ P LHNA+LSK LGK W+ L   ++RP+VEEAERLRV \n"+
"Sbjct  167  VRRPMNAFMVWAKVERKRLADENPDLHNADLSKMLGKKWKGLTPQDRRPYVEEAERLRVI  226\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRRKSVKNG  185\n"+
"            H ++HP+YKY+PRRRK VK G\n"+
"Sbjct  227  HLQEHPNYKYRPRRRKQVKRG  247\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_009044439.1<a name=XP_009044439></a> hypothetical protein LOTGIDRAFT_184905, partial [Lottia gigantea]\n"+
" ESP04930.1<a name=ESP04930></a> hypothetical protein LOTGIDRAFT_184905, partial [Lottia gigantea] \n"+
" \n"+
"Length=319\n"+
"\n"+
" Score = 119 bits (298),  Expect = 4e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/77 (64%), Positives = 64/77 (83%), Gaps = 0/77 (0%)\n"+
"\n"+
"Query  103  PHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLR  162\n"+
"            P VKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W+L+ ESEKRPF++EA+RLR\n"+
"Sbjct  78   PRVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKLMTESEKRPFIDEAKRLR  137\n"+
"\n"+
"Query  163  VQHKKDHPDYKYQPRRR  179\n"+
"              H K+HPDYKY+PRR+\n"+
"Sbjct  138  AIHMKEHPDYKYRPRRK  154\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_011445203.1<a name=XP_011445203></a> PREDICTED: transcription factor SOX-11-like [Crassostrea gigas]\n"+
" EKC30339.1<a name=EKC30339></a> Putative transcription factor SOX-14 [Crassostrea gigas]  \n"+
"Length=339\n"+
"\n"+
" Score = 120 bits (300),  Expect = 4e-27, Method: Compositional matrix adjust.\n"+
" Identities = 52/98 (53%), Positives = 76/98 (78%), Gaps = 1/98 (1%)\n"+
"\n"+
"Query  100  KNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAE  159\n"+
"            K   HVKRPMNAFMVW+Q  RRK+++  P +HNAE+SK LGK W+ LNE++++PF+EEAE\n"+
"Sbjct  30   KQSNHVKRPMNAFMVWSQLERRKISEVSPDMHNAEISKRLGKRWKTLNETDRQPFIEEAE  89\n"+
"\n"+
"Query  160  RLRVQHKKDHPDYKYQPRRR-KSVKNGQAEAEEATEQT  196\n"+
"            RLR+ H +++PDYKY+PR++ K V   +++  + T +T\n"+
"Sbjct  90   RLRLLHMQEYPDYKYRPRKKAKPVTKSESKVSKPTSKT  127\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_010789005.1<a name=XP_010789005></a> PREDICTED: transcription factor SOX-7 [Notothenia coriiceps] \n"+
" \n"+
"Length=392\n"+
"\n"+
" Score = 120 bits (302),  Expect = 4e-27, Method: Compositional matrix adjust.\n"+
" Identities = 55/92 (60%), Positives = 70/92 (76%), Gaps = 0/92 (0%)\n"+
"\n"+
"Query  92   PVRVNGSSKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEK  151\n"+
"            P R       +P ++RPMNAFMVWA+  R++LA Q P LHNAELSK LGK W+ L   +K\n"+
"Sbjct  30   PQRTPADKAPEPRIRRPMNAFMVWAKDERKRLAVQNPDLHNAELSKMLGKSWKALTPPDK  89\n"+
"\n"+
"Query  152  RPFVEEAERLRVQHKKDHPDYKYQPRRRKSVK  183\n"+
"            RP+VEEAERLRVQH +D+P+YKY+PRR+K +K\n"+
"Sbjct  90   RPYVEEAERLRVQHMQDYPNYKYRPRRKKQLK  121\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">KFB47267.1<a name=KFB47267></a> sex-determining region y protein, sry [Anopheles sinensis]  \n"+
"Length=216\n"+
"\n"+
" Score = 116 bits (291),  Expect = 4e-27, Method: Compositional matrix adjust.\n"+
" Identities = 48/76 (63%), Positives = 62/76 (82%), Gaps = 0/76 (0%)\n"+
"\n"+
"Query  104  HVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRV  163\n"+
"            H+KRPMNAFMVW++  RRK+A   P +HN+E+SK LG  W+LL E EKRPF++EA+RLR \n"+
"Sbjct  17   HIKRPMNAFMVWSRGQRRKMAQDNPKMHNSEISKNLGAQWKLLTEGEKRPFIDEAKRLRA  76\n"+
"\n"+
"Query  164  QHKKDHPDYKYQPRRR  179\n"+
"             H K+HPDYKY+PRR+\n"+
"Sbjct  77   LHMKEHPDYKYRPRRK  92\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_014671379.1<a name=XP_014671379></a> PREDICTED: transcription factor Sox-3-A-like [Priapulus caudatus] \n"+
" \n"+
"Length=346\n"+
"\n"+
" Score = 120 bits (300),  Expect = 4e-27, Method: Compositional matrix adjust.\n"+
" Identities = 49/79 (62%), Positives = 64/79 (81%), Gaps = 0/79 (0%)\n"+
"\n"+
"Query  101  NKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAER  160\n"+
"            N  HVKRPMNAFMVW++  RRK+A + P +HN+E+SK LG  W++L E EKRPF++EA+R\n"+
"Sbjct  69   NMDHVKRPMNAFMVWSRGQRRKMAQENPKMHNSEISKRLGAEWKILTEEEKRPFIDEAKR  128\n"+
"\n"+
"Query  161  LRVQHKKDHPDYKYQPRRR  179\n"+
"            LR  H KD+PDYKY+PRR+\n"+
"Sbjct  129  LRALHMKDYPDYKYRPRRK  147\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_012409532.1<a name=XP_012409532></a> PREDICTED: transcription factor SOX-18 [Sarcophilus harrisii] \n"+
" \n"+
"Length=344\n"+
"\n"+
" Score = 120 bits (300),  Expect = 4e-27, Method: Compositional matrix adjust.\n"+
" Identities = 52/80 (65%), Positives = 65/80 (81%), Gaps = 0/80 (0%)\n"+
"\n"+
"Query  105  VKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEAERLRVQ  164\n"+
"            ++RPMNAFMVWA+  R++LA Q P LHNA LSK LG+ W+ L  +EKRPFVEEAERLR+Q\n"+
"Sbjct  10   IRRPMNAFMVWAKDERKRLAQQNPDLHNAVLSKMLGQAWKALTTAEKRPFVEEAERLRIQ  69\n"+
"\n"+
"Query  165  HKKDHPDYKYQPRRRKSVKN  184\n"+
"            H +DHP+YKY+PRR+K  K \n"+
"Sbjct  70   HLQDHPNYKYRPRRKKQAKK  89\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
">XP_006745983.1<a name=XP_006745983></a> PREDICTED: transcription factor COE3 [Leptonychotes weddellii] \n"+
" \n"+
"Length=618\n"+
"\n"+
" Score = 123 bits (309),  Expect = 4e-27, Method: Compositional matrix adjust.\n"+
" Identities = 53/88 (60%), Positives = 70/88 (80%), Gaps = 0/88 (0%)\n"+
"\n"+
"Query  99   SKNKPHVKRPMNAFMVWAQAARRKLADQYPHLHNAELSKTLGKLWRLLNESEKRPFVEEA  158\n"+
"            + ++  ++RPMNAFMVWA+  R++LA Q P LHNA LSK LGK W+ L+ +EKRPFVEEA\n"+
"Sbjct  25   AADESRIRRPMNAFMVWAKDERKRLAQQNPDLHNAVLSKMLGKAWKELSTAEKRPFVEEA  84\n"+
"\n"+
"Query  159  ERLRVQHKKDHPDYKYQPRRRKSVKNGQ  186\n"+
"            ERLRVQH +DHP+YKY+PRR+K  +  +\n"+
"Sbjct  85   ERLRVQHLRDHPNYKYRPRRKKQARKAR  112\n"+
"\n"+
"\n"+
"\n"+
"</PRE>\n"+
"<PRE>\n"+
"Lambda      K        H        a         alpha\n"+
"   0.309    0.127    0.384    0.792     4.96 \n"+
"\n"+
"Gapped\n"+
"Lambda      K        H        a         alpha    sigma\n"+
"   0.267   0.0410    0.140     1.90     42.6     43.6 \n"+
"\n"+
"Effective search space used: 1719848705550\n"+
"\n"+
"\n"+
"  Database: nr70\n"+
"    Posted date:  Oct 17, 2016  9:53 AM\n"+
"  Number of letters in database: 8,746,506,771\n"+
"  Number of sequences in database:  27,180,568\n"+
"\n"+
"\n"+
"\n"+
"Matrix: BLOSUM62\n"+
"Gap Penalties: Existence: 11, Extension: 1\n"+
"Neighboring words threshold: 11\n"+
"Window for multiple hits: 40\n"+
"</PRE></PRE>\n"
}


