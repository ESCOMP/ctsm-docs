.. _rst_Crops and Irrigation:

Crops and Irrigation
========================

.. _Summary of CLM5.0 updates relative to the CLM4.5:

Summary of CLM5.0 updates relative to the CLM4.5
-----------------------------------------------------

We describe here the complete crop and irrigation parameterizations that
appear in CLM5.0. Corresponding information for CLM4.5 appeared on the
CLM4.5 web site in a pdf document independent of the CLM4.5 Technical
Note (:ref:`Oleson et al. 2013 <Olesonetal2013>`). 

CLM5.0 includes the following updates to the CROP option, where CROP
refers to the interactive crop management model and is included by default with the BGC configuration:

- New crop functional types

- All crop areas are actively managed

- Fertilization rates updated based on crop type and geographic region

- New Irrigation triggers

- Phenological triggers vary by latitude for some crop types

- Ability to simulate transient crop management

- Adjustments to allocation and phenological parameters

- Crops reaching their maximum LAI triggers the grain fill phase

- Grain C and N pools are included in a 1-year product pool

- C for annual crop seeding comes from the grain C pool

- Initial seed C for planting is increased from 1 to 3 g C/m^2 


These updates appear in detail in the sections below. Many also appear in
Levis et al. (:ref:`2016 <Levisetal2016>`).

.. _The crop model:

The crop model
-------------------

Introduction
^^^^^^^^^^^^^^^^^^^

Groups developing Earth System Models generally account for the human
footprint on the landscape in simulations of historical and future
climates. Traditionally we have represented this footprint with natural
vegetation types and particularly grasses because they resemble many
common crops. Most modeling efforts have not incorporated more explicit
representations of land management such as crop type, planting,
harvesting, tillage, fertilization, and irrigation, because global scale
datasets of these factors have lagged behind vegetation mapping. As this
begins to change, we increasingly find models that will simulate the
biogeophysical and biogeochemical effects not only of natural but also
human-managed land cover.

AgroIBIS is a state-of-the-art land surface model with options to
simulate dynamic vegetation (:ref:`Kucharik et al. 2000 <Kuchariketal2000>`) and interactive
crop management (:ref:`Kucharik and Brye 2003 <KucharikBrye2003>`). The interactive crop
management parameterizations from AgroIBIS (March 2003 version) were
coupled as a proof-of-concept to the Community Land Model version 3
[CLM3.0, :ref:`Oleson et al. (2004) <Olesonetal2004>`] (not published), then coupled to the
CLM3.5 (:ref:`Levis et al. 2009 <Levisetal2009>`) and later released to the community with
CLM4CN (:ref:`Levis et al. 2012 <Levisetal2012>`), with additional updates 
available by request after the release of CLM4.5 (:ref:`Levis et al. 2016 <Levisetal2016>`).

With interactive crop management and, therefore, a more accurate
representation of agricultural landscapes, we hope to improve the CLM’s
simulated biogeophysics and biogeochemistry. These advances may improve
fully coupled simulations with the Community Earth System Model (CESM),
while helping human societies answer questions about changing food,
energy, and water resources in response to climate, environmental, land
use, and land management change (e.g., :ref:`Kucharik and Brye 2003 <KucharikBrye2003>`; :ref:`Lobell et al. 2006 <Lobelletal2006>`).
As implemented here, the crop model uses the same physiology as the
natural vegetation, though uses different crop-specific parameter values,
phenology, and allocation, as well as fertilizer and irrigation management.

.. _Crop plant functional types:

Crop plant functional types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To allow crops to coexist with natural vegetation in a grid cell, the 
vegetated land unit is separated into a naturally vegetated land unit and
a managed crop land unit. Unlike the plant functional types (pfts) in the
naturally vegetated land unit, the managed crop pfts in the managed crop 
land unit do not share soil columns and thus permit for differences in the 
land management between crops. Each crop type has a rainfed and an irrigated 
pft that are on independent soil columns. Crop grid cell coverage is assigned from 
satellite data (similar to all natural pfts), and the managed crop type
proportions within the crop area is based on the dataset created by
(:ref:`Portmann et al. 2010 <Portmannetal2010>`) for present day. New in CLM5, crop area is
extrapolated through time using the dataset provided by Land Use Model 
Intercomparison Project (LUMIP), which is part of CMIP6 Land use timeseries 
(:ref:`Lawrence et al. 2016 <Lawrenceetal2016>`). For more details about how
crop distributions are determined, see chapter 26 on :ref:`rst_Transient Landcover Change`. 

CLM5 includes eight actively managed crop types
(temperate soybean, tropical soybean, temperate corn, tropical 
corn, spring wheat, cotton, rice, and sugarcane) that are chosen 
based on the availability of corresponding algorithms in AgroIBIS and as 
developed by Badger and Dirmeyer (:ref:`2015 <BadgerandDirmeyer2015>`) and
described by Levis et al. (:ref:`2016 <Levisetal2016>`). The representations of
sugarcane, rice, cotton, tropical corn, and tropical soy are new in CLM5.
Sugarcane and tropical corn are both C4 plants and are therefore represented
using the temperate corn functional form. Tropical soybean uses the temperate
soybean functional form, while rice and cotton use the wheat functional form.
In tropical regions, parameter values were developed for the Amazon Basin, and planting
date window is shifted by six months relative to the Northern Hemisphere. 

In addition, CLM’s default list of plant functional types (pfts) includes an
irrigated and unirrigated unmanaged C3 crop (Table 25.1) treated as a second C3 grass,
The unmanaged C3 crop is only used when the crop model is not active and 
has grid cell coverage assigned from satellite data, and 
the unmanaged C3 irrigated crop type is currently not used 
since irrigation requires the crop model to be active.
The default list of pfts also includes twenty-three inactive crop pfts 
that do not yet have associated parameters required for active management. 
Each of the inactive crop types is simulated using the parameters of the 
spatially closest associated crop type that is most similar to the functional type (e.g., C3 or C4), 
which is required to maintain similar phenological parameters based on temperature thresholds.
Information detailing which parameters are used for each crop type is 
included in Table 25.1. It should be noted that analysis with pft-level history output merges
all crop types into the actively managed crop type, so analysis 
of crop-specific output will require use of the land surface dataset to 
remap the yields of each actively and inactively managed crop type.

.. _Phenology:

Phenology
^^^^^^^^^^^^^^^^

CLM4.5CN includes evergreen, seasonally deciduous (responding to changes
in day length), and stress deciduous (responding to changes in
temperature and/or soil moisture) phenology algorithms (Chapter 14). In
CLM4.5CNcrop we have added the AgroIBIS crop phenology algorithm,
consisting of three distinct phases.

Phase 1 starts at planting and ends with leaf emergence, phase 2
continues from leaf emergence to the beginning of grain fill, and phase
3 starts from the beginning of grain fill and ends with physiological
maturity and harvest.

.. _Planting:

Planting
'''''''''''''''''

Corn and temperate cereals must meet the following requirements between
April 1\ :sup:`st` and June 14\ :sup:`th` for planting in the northern hemisphere (NH):

.. math::
   :label: 25.1

   \begin{array}{l} 
   {T_{10d} >T_{p} } \\ 
   {T_{10d}^{\min } >T_{p}^{\min } }  \\ 
   {GDD_{8} \ge GDD_{\min } } 
   \end{array}

where :math:`{T}_{10d}` is the 10-day running mean of :math:`{T}_{2m}`, (the simulated 2-m air
temperature at every model time step) and :math:`T_{10d}^{\min}`  is
the 10-day running mean of :math:`T_{2m}^{\min }`  (the daily minimum of
:math:`{T}_{2m}`. :math:`{T}_{p}` and :math:`T_{p}^{\min }`  are crop-specific coldest planting temperatures
(:numref:`Table Crop plant functional types`), :math:`{GDD}_{8}` is the 20-year running mean growing
degree-days (units are degree-days or :sup:`o` days) tracked
from April through September (NH) base 8\ :sup:`o` C with
maximum daily increments of 30\ :sup:`o` days (see Eq.XXX ), and
:math:`{GDD}_{min }`\ is the minimum growing degree day requirement
(:numref:`Table Crop plant functional types`). Soy must meet the same requirements but between May
1\ :sup:`st` and June 14\ :sup:`th` for planting. If the
requirements in Eq. are not met by June 14\ :sup:`th`, then corn,
soybean, and temperate cereals are still planted on June
15\ :sup:`th` as long as  :math:`{GDD}_{8} > 0`. In
the southern hemisphere (SH) the NH requirements apply 6 months later.

:math:`{GDD}_{8}` does not change as quickly as :math:`{T}_{10d}` and :math:`T_{10d}^{\min }`, so
it determines whether the crop can be planted in a grid cell, while the
two faster-changing variables determine when the crop may be planted.

At planting, each crop is assigned 1 g leaf C m\ :sup:`-2` pft
column area to be transferred to the leaves upon leaf emergence. An
equivalent amount of seed leaf N is assigned given the pft’s C to N
ratio for leaves (:math:`{CN}_{leaf}`). (This differs from AgroIBIS,
which uses a seed leaf area index instead of seed C.)

At planting, the model updates the average growing degree-days necessary
for the crop to reach vegetative and physiological maturity,
:math:`{GDD}_{mat}`, according to the following AgroIBIS rules:

.. math::
   :label: 25.2

   \begin{array}{l} {GDD_{{\rm mat}}^{{\rm corn}} =0.85GDD_{{\rm 8}} {\rm \; \; \; and\; \; \; 950}<GDD_{{\rm mat}}^{{\rm corn}} <1850{}^\circ {\rm days}} \\ {GDD_{{\rm mat}}^{{\rm temp.\; cereals}} =GDD_{{\rm 0}} {\rm \; \; \; and\; \; \; }GDD_{{\rm mat}}^{{\rm temp.\; cereals}} <1700{}^\circ {\rm days}} \\ {GDD_{{\rm mat}}^{{\rm soy}} =GDD_{{\rm 10}} {\rm \; \; \; and\; \; \; }GDD_{{\rm mat}}^{{\rm soy}} <1700{}^\circ {\rm days}} \end{array}

where :math:`{GDD}_{10}` is the 20-year running mean growing
degree-days tracked from April through September (NH) base
10\ :math:`{}^\circ`\ C with maximum daily increments of
30\ :math:`{}^\circ`\ days. Eq. shows how we calculate
:math:`{GDD}_{0}`, :math:`{GDD}_{8}`, and :math:`{GDD}_{10}`:

.. math::
   :label: 25.3

   \begin{array}{l} {GDD_{{\rm 0}} =GDD_{0} +T_{2{\rm m}} -T_{f} {\rm \; \; \; where\; \; \; 0}\le T_{2{\rm m}} -T_{f} \le 26{}^\circ {\rm days}} \\ {GDD_{{\rm 8}} =GDD_{8} +T_{2{\rm m}} -T_{f} -8{\rm \; \; \; where\; \; \; 0}\le T_{2{\rm m}} -T_{f} -8\le 30{}^\circ {\rm days}} \\ {GDD_{{\rm 10}} =GDD_{10} +T_{2{\rm m}} -T_{f} -10{\rm \; \; \; where\; \; \; 0}\le T_{2{\rm m}} -T_{f} -10\le 30{}^\circ {\rm days}} \end{array}

where, if :math:`{T}_{2m}` -  :math:`{T}_{f}` takes on values
outside the above ranges, then it equals the minimum or maximum value in
the range. Also  :math:`{T}_{f}` equals 273.15 K,
:math:`{T}_{2m}` has units of K, and *GDD* has units of :sup:`o`\ days.

.. _Leaf emergence:

Leaf emergence
'''''''''''''''''''''''

According to AgroIBIS, leaves may emerge when the growing degree-days of
soil temperature to 0.05 m depth tracked since planting
(:math:`GDD_{T_{soi} }` ) reaches 1 to 5% of :math:`{GDD}_{mat}`
(:numref:`Table Crop plant functional types`). :math:`GDD_{T_{soi} }` is base 8, 0, and
10\ :math:`{}^\circ`\ C for corn, soybean, and temperate cereals. 
Leaf onset, as defined in the CN part of the model, occurs in the first
time step of phase 2, at which moment all seed C is transferred to leaf
C. Subsequently, the leaf area index generally increases and reaches
a maximum value during phase 2.

.. _Grain fill:

Grain fill
'''''''''''''''''''

Phase 3 begins in one of two ways. The first potential trigger is based on temperature, similar to phase 2. A variable tracked since
planting like :math:`GDD_{T_{soi} }`  but for 2-m air temperature,
:math:`GDD_{T_{{\rm 2m}} }`, must reach a heat unit threshold, *h*,
of 40 to 65% of  :math:`{GDD}_{mat}` (:numref:`Table Crop plant functional types`). 
For crops with the C4 photosynthetic pathway (temperate and tropical corn, sugarcane),
the :math:`{GDD}_{mat}` is based on an empirical function and ranges between 950 and 1850.
The second potential trigger for phase 3 is based on leaf area index. 
When the maximum value of leaf area index is reached in phase 2, phase 3 begins. 
In phase 3, the leaf area index begins to decline in
response to a background litterfall rate calculated as the inverse of
leaf longevity for the pft as done in the CN part of the model.

.. _Harvest:

Harvest
''''''''''''''''

Harvest is assumed to occur as soon as the crop reaches maturity. When
:math:`GDD_{T_{{\rm 2m}} }` reaches 100% of :math:`{GDD}_{mat}` or
the number of days past planting reaches a crop-specific maximum 
(:numref:`Table Crop plant functional types`)[update table reference], then the crop is harvested. 
Harvest occurs in one time step using
CN’s leaf offset algorithm. Variables track the flow of grain C and
N to food and of live stem C and N to litter. Putting live
stem C and N into the litter pool is in contrast to the approach for unmanaged PFTs which
puts live stem C and N into dead stem pools first. Leaf and root C and N pools
are routed to the litter pools in the same manner as natural vegetation. In CLM5, food C and N
are routed to a grain product pool where the C and N decay to the atmosphere over one year,
similar in structure to the wood product pools. 

.. _Allocation:

Allocation
^^^^^^^^^^^^^^^^^

Allocation responds to the same phases as phenology (section 20.2.3).
Simulated C assimilation begins every year upon leaf emergence in phase
2 and ends with harvest at the end of phase 3; therefore, so does the
allocation of such C to the crop’s leaf, live stem, fine root, and
reproductive pools.

.. _Leaf emergence to grain fill:

Leaf emergence to grain fill
'''''''''''''''''''''''''''''''''''''

During phase 2, the allocation coefficients (fraction of available C) to
each C pool are defined as:

.. math::
   :label: 25.4

   \begin{array}{l} {a_{repr} =0} \\ {a_{froot} =a_{froot}^{i} -(a_{froot}^{i} -a_{froot}^{f} )\frac{GDD_{T_{{\rm 2m}} } }{GDD_{{\rm mat}} } {\rm \; \; \; where\; \; \; }\frac{GDD_{T_{{\rm 2m}} } }{GDD_{{\rm mat}} } \le 1} \\ {a_{leaf} =(1-a_{froot} )\cdot \frac{a_{leaf}^{i} (e^{-b} -e^{-b\frac{GDD_{T_{{\rm 2m}} } }{h} } )}{e^{-b} -1} {\rm \; \; \; where\; \; \; }b=0.1} \\ {a_{livestem} =1-a_{repr} -a_{froot} -a_{leaf} } \end{array}

where :math:`a_{leaf}^{i}` , :math:`a_{froot}^{i}` , and
:math:`a_{froot}^{f}`  are initial and final values of these
coefficients (:numref:`Table Crop pfts`), and *h* is a heat unit threshold defined in
section 20.2.3. At a crop-specific maximum leaf area index,
:math:`{L}_{max}` (:numref:`Table Crop pfts`), carbon allocation is directed
exclusively to the fine roots.

.. _Grain fill to harvest:

Grain fill to harvest
''''''''''''''''''''''''''''''

The calculation of :math:`a_{froot}`  remains the same from phase 2 to
phase 3. Other allocation coefficients change to:

.. math::
   :label: 25.5

   \begin{array}{lr} 
   a_{leaf} =a_{leaf}^{i,3} & {\rm when} \quad a_{leaf}^{i,3} \le a_{leaf}^{f} \quad {\rm else} \\ 
   a_{leaf} =a_{leaf} \left(1-\frac{GDD_{T_{{\rm 2m}} } -h}{GDD_{{\rm mat}} d_{L} -h} \right)^{d_{alloc}^{leaf} } \ge a_{leaf}^{f} & {\rm where} \quad \frac{GDD_{T_{{\rm 2m}} } -h}{GDD_{{\rm mat}} d_{L} -h} \le 1 \\ 
    \\ 
   a_{livestem} =a_{livestem}^{i,3} & {\rm when} \quad a_{livestem}^{i,3} \le a_{livestem}^{f} \quad {\rm else} \\ 
   a_{livestem} =a_{livestem} \left(1-\frac{GDD_{T_{{\rm 2m}} } -h}{GDD_{{\rm mat}} d_{L} -h} \right)^{d_{alloc}^{stem} } \ge a_{livestem}^{f} & {\rm where} \quad \frac{GDD_{T_{{\rm 2m}} } -h}{GDD_{{\rm mat}} d_{L} -h} \le 1 \\ 
    \\ 
   a_{repr} =1-a_{froot} -a_{livestem} -a_{leaf} 
   \end{array}

where :math:`a_{leaf}^{i,3}`  and :math:`a_{livestem}^{i,3}`  (initial
values) equal the last :math:`a_{leaf}`  and :math:`a_{livestem}` 
calculated in phase 2, :math:`d_{L}` , :math:`d_{alloc}^{leaf}`  and
:math:`d_{alloc}^{stem}`  are leaf area index and leaf and stem
allocation decline factors, and :math:`a_{leaf}^{f}`  and
:math:`a_{livestem}^{f}`  are final values of these allocation
coefficients (:numref:`Table Crop pfts`).

Harvest to seed
''''''''''''''''''''''''''''''

In CLM5, the C and N required for crop seeding is removed from the grain
product pool during harvest and used to seed crops in the subsequent year.  

.. _General comments:

General comments
^^^^^^^^^^^^^^^^^^^^^^^

C and N accounting now includes new pools and fluxes pertaining to live
stems and reproductive tissues. For example, the calculations of growth
respiration, above ground net primary production, litter fall, and
displayed vegetation all now account for reproductive C.

We track allocation to reproductive C separately from CN’s allocation to
other C pools but within the CN framework. CN uses
:math:`{\textstyle\frac{a_{root} }{a_{leaf} }}`  and :math:`{\textstyle\frac{a_{livestem} }{a_{leaf} }}`  to calculate C and
N allometry and plant N demand.

Stem area index (*S*) is equal to 0.1\ *L* for corn and 0.2\ *L* for
other crops, as in AgroIBIS, where *L* is the leaf area index. All live
C and N pools go to 0 after crop harvest, but the *S* is kept at 0.25 to
simulate a post-harvest “stubble” on the ground.

Crop heights at the top and bottom of the canopy, :math:`{z}_{top}`
and :math:`{z}_{bot}` (m), come from the AgroIBIS formulation:

.. math::
   :label: 25.6

   \begin{array}{l} 
   {z_{top} =z_{top}^{\max } \left(\frac{L}{L_{\max } -1} \right)^{2} \ge 0.05{\rm \; where\; }\frac{L}{L_{\max } -1} \le 1} \\ 
   {z_{bot} =0.02{\rm m}} 
   \end{array}

The CN part of the model keeps track of a term representing excess
maintenance respiration that for perennial pfts or pfts with C storage
may be extracted from later gross primary production. Later extraction
cannot continue to happen after harvest for annual crops, so at harvest
we turn the excess respiration pool into a flux that extracts
CO\ :sub:`2` directly from the atmosphere. This way we eliminate
any excess maintenance respiration remaining at harvest as if such
respiration had not taken place.

In the list of plant physiological and other parameters used by the CLM,
we started the managed crops with the existing values assigned to the
unmanaged C3 crop. Then we changed the following parameters to
distinguish corn, soybean, and temperate cereals from the unmanaged C3
crop and from each other:

#. Growth respiration coefficient from 0.30 to the AgroIBIS value of
   0.25.

#. Fraction of leaf N in the Rubisco enzyme from 0.1 to 0.2 g N Rubisco
   g\ :sup:`-1` N leaf for temperate cereals to increase
   productivity (not chosen based on AgroIBIS).

#. Fraction of current photosynthesis displayed as growth changed from
   0.5 to 1 (not chosen based on AgroIBIS).

#. CLM4.5CN curve for the effect of temperature on photosynthesis
   instead of crop-specific curves from AgroIBIS.

#. Quantum efficiency at 25\ :sup:`o`\ C,
   :math:`\alpha` , from 0.06 to 0.04 *µ*\ mol CO\ :sub:`2`  *µ*\ mol\ :sup:`-1` photon for C4 crops (corn and unmanaged C4
   crop), using CLM4.5CN’s C4 grass value.

#. Slope, *m*, of conductance-to-photosynthesis relationship from 9 to 4 for C4 crops as in AgroIBIS.

#. Specific leaf areas, *SLA*, to the AgroIBIS values (:numref:`Table Crop plant functional types`).

#. Leaf orientation, :math:`\chi _{L}`, to the AgroIBIS values (:numref:`Table Crop plant functional types`).

#. Soil moisture photosynthesis limitation factor,
   :math:`\beta _{t}`, for soybeans multiplied as in AgroIBIS by 1.25
   for increased drought tolerance.

.. _Table Crop plant functional types:

.. table:: Crop plant functional types (pfts) in CLM5BGCCROP and their parameters relating to phenology and morphology. Numbers in the first column correspond to the list of pfts in :numref:`Table Plant functional types`.

 ===  ===========================  =================  ===========================  =============================  ===========================  =============================  =============================  ===========================  ===========================  ===================================  =======================
 IVT  Phenological Type            :math:`T_{p}` (K)  :math:`{GDD}_{min}` (ºdays)  base temperature for GDD (ºC)  :math:`{GDD}_{mat}` (ºdays)  Phase 2 % :math:`{GDD}_{mat}`  Phase 3 % :math:`{GDD}_{mat}`  Harvest: days past planting  :math:`z_{top}^{\max }` (m)  SLA (m :sup:`2` leaf g :sup:`-1` C)  :math:`\chi _{L}` index
 ===  ===========================  =================  ===========================  =============================  ===========================  =============================  =============================  ===========================  ===========================  ===================================  =======================
  17  rainfed temperate corn                  279.15                           50                              8  950-1850                                              0.03                           0.65  :math:`\mathrm{\le}`\ 165                           2.50                                 0.05                    -0.50
  18  irrigated temperate corn                279.15                           50                              8  950-1850                                              0.03                           0.65  :math:`\mathrm{\le}`\ 165                           2.50                                 0.05                    -0.50
  19  rainfed spring wheat                    272.15                           50                              0  :math:`\mathrm{\le}`\ 1700                            0.05                           0.60  :math:`\mathrm{\le}`\ 150                           1.20                                 0.04                     0.65
  20  irrigated spring wheat                  272.15                           50                              0  :math:`\mathrm{\le}`\ 1700                            0.05                           0.60  :math:`\mathrm{\le}`\ 150                           1.20                                 0.04                     0.65
  23  rainfed temperate soybean               279.15                           50                             10  :math:`\mathrm{\le}`\ 1900                            0.03                           0.50  :math:`\mathrm{\le}`\ 150                           0.75                                 0.04                    -0.50
  24  irrigated temperate soybean             279.15                           50                             10  :math:`\mathrm{\le}`\ 1900                            0.03                           0.50  :math:`\mathrm{\le}`\ 150                           0.75                                 0.04                    -0.50
  41  rainfed cotton                          283.15                           50                             10  :math:`\mathrm{\le}`\ 1700                            0.03                           0.50  :math:`\mathrm{\le}`\ 160                           1.50                                 0.04                    -0.50
  42  irrigated cotton                        283.15                           50                             10  :math:`\mathrm{\le}`\ 1700                            0.03                           0.50  :math:`\mathrm{\le}`\ 160                           1.50                                 0.04                    -0.50
  61  rainfed rice                            283.15                           50                             10  :math:`\mathrm{\le}`\ 2100                            0.01                           0.40  :math:`\mathrm{\le}`\ 150                           1.80                                 0.04                     0.65
  62  irrigated rice                          283.15                           50                             10  :math:`\mathrm{\le}`\ 2100                            0.01                           0.40  :math:`\mathrm{\le}`\ 150                           1.80                                 0.04                     0.65
  67  rainfed sugarcane                       283.15                           50                             10  950-1850                                              0.03                           0.65  :math:`\mathrm{\le}`\ 300                           4.00                                 0.05                    -0.50
  68  irrigated sugarcane                     283.15                           50                             10  950-1850                                              0.03                           0.65  :math:`\mathrm{\le}`\ 300                           4.00                                 0.05                    -0.50
  75  rainfed tropical corn                   283.15                           50                             10  :math:`\mathrm{\le}`\ 1800                            0.03                           0.50  :math:`\mathrm{\le}`\ 160                           2.50                                 0.05                    -0.50
  76  irrigated tropical corn                 283.15                           50                             10  :math:`\mathrm{\le}`\ 1800                            0.03                           0.50  :math:`\mathrm{\le}`\ 160                           2.50                                 0.05                    -0.50
  77  rainfed tropical soybean                283.15                           50                             10  :math:`\mathrm{\le}`\ 2100                            0.03                           0.50  :math:`\mathrm{\le}`\ 150                           1.00                                 0.04                    -0.50
  78  irrigated tropical soybean              283.15                           50                             10  :math:`\mathrm{\le}`\ 2100                            0.03                           0.50  :math:`\mathrm{\le}`\ 150                           1.00                                 0.04                    -0.50
 ===  ===========================  =================  ===========================  =============================  ===========================  =============================  =============================  ===========================  ===========================  ===================================  =======================

Notes: :math:`T_{p}` is the minimum planting temperatures. :math:`{GDD}_{min}` is the lowest
(for planting) 20-year running mean growing degree-days base on the base temperature in the 5\ :sup:`th` column, tracked from April to September (NH).
:math:`{GDD}_{mat}` is a crop’s 20-year running mean growing
degree-days needed for vegetative and physiological maturity. Harvest
occurs at 100%\ :math:`{GDD}_{mat}` or when the days past planting
reach the number in the 9\ :sup:`th` column. Crop growth phases
are described in the text. :math:`z_{top}^{\max }`  is the maximum
top-of-canopy height of a crop, *SLA* is specific leaf area. :math:`\chi _{L}` is the leaf
orientation index, equals -1 for vertical, 0 for
random, and 1 for horizontal leaf orientation.

.. _Table Crop pfts:

.. table:: Crop pfts in CLM5BGCCROP and their parameters relating to allocation. Numbers in the first column correspond to the list of pfts in :numref:`Table Plant functional types`.

 ===  ===========================  ====================  ===========================================  =====================  =====================  ====================  ========================  =============  ========================  ========================
 IVT  Phenological Type            :math:`a_{leaf}^{i}`  :math:`{L}_{max}` (m :sup:`2`  m :sup:`-2`)  :math:`a_{froot}^{i}`  :math:`a_{froot}^{f}`  :math:`a_{leaf}^{f}`  :math:`a_{livestem}^{f}`  :math:`d_{L}`  :math:`d_{alloc}^{stem}`  :math:`d_{alloc}^{leaf}`
 ===  ===========================  ====================  ===========================================  =====================  =====================  ====================  ========================  =============  ========================  ========================
  17  rainfed temperate corn                       0.80                                            5                    0.4                   0.05                     0                      0.00           1.05                         2                         5
  18  irrigated temperate corn                     0.80                                            5                    0.4                   0.05                     0                      0.00           1.05                         2                         5
  19  rainfed spring wheat                         0.90                                            7                    0.1                   0.00                     0                      0.05           1.05                         1                         3
  20  irrigated spring wheat                       0.90                                            7                    0.1                   0.00                     0                      0.05           1.05                         1                         3
  23  rainfed temperate soybean                    0.85                                            6                    0.2                   0.20                     0                      0.30           1.05                         5                         2
  24  irrigated temperate soybean                  0.85                                            6                    0.2                   0.20                     0                      0.30           1.05                         5                         2
  41  rainfed cotton                               0.85                                            6                    0.2                   0.20                     0                      0.30           1.05                         5                         2
  42  irrigated cotton                             0.85                                            6                    0.2                   0.20                     0                      0.30           1.05                         5                         2
  61  rainfed rice                                 0.75                                            7                    0.1                   0.00                     0                      0.05           1.05                         1                         3
  62  irrigated rice                               0.75                                            7                    0.1                   0.00                     0                      0.05           1.05                         1                         3
  67  rainfed sugarcane                            0.80                                            5                    0.4                   0.05                     0                      0.00           1.05                         2                         5
  68  irrigated sugarcane                          0.80                                            5                    0.4                   0.05                     0                      0.00           1.05                         2                         5
  75  rainfed tropical corn                        0.80                                            5                    0.4                   0.05                     0                      0.00           1.05                         2                         5
  76  irrigated tropical corn                      0.80                                            5                    0.4                   0.05                     0                      0.00           1.05                         2                         5
  77  rainfed tropical soybean                     0.85                                            6                    0.2                   0.20                     0                      0.30           1.05                         5                         2
  78  irrigated tropical soybean                   0.85                                            6                    0.2                   0.20                     0                      0.30           1.05                         5                         2
 ===  ===========================  ====================  ===========================================  =====================  =====================  ====================  ========================  =============  ========================  ========================

Notes: Crop growth phases and corresponding variables are described in
the text

.. _The irrigation model:

The irrigation model
-------------------------

The CLM includes the option to irrigate cropland areas that are equipped
for irrigation. The application of irrigation responds dynamically to
the soil moisture conditions simulated by the CLM. This irrigation
algorithm is based loosely on the implementation of 
:ref:`Ozdogan et al. (2010) <Ozdoganetal2010>`.

When irrigation is enabled, the crop areas of each grid cell are divided
into irrigated and rainfed fractions according to a dataset of areas
equipped for irrigation (:ref:`Portmann et al. 2010 <Portmannetal2010>`). 
Irrigated and rainfed crops are placed on separate soil columns, so that 
irrigation is only applied to the soil beneath irrigated crops.

In irrigated croplands, a check is made once per day to determine
whether irrigation is required on that day. This check is made in the
first time step after 6 AM local time. Irrigation is required if crop
leaf area :math:`>` 0, and the available soil water is below a specified 
threshold.

The soil moisture deficit :math:`D_{irrig}` is 

.. math::
   :label: 25.61

   D_{irrig} = \left\{
   \begin{array}{lr}    
   w_{thresh} - w_{avail} &\qquad w_{thresh} > w_{avail} \\
   0 &\qquad w_{thresh} \le w_{avail}    
   \end{array} \right\}

where :math:`w_{thresh}` is the irrigation moisture threshold (mm) and 
:math:`w_{avail}` is the available moisture (mm).  The moisture threshold 
is

.. math::
   :label: 25.62

   w_{thresh} = f_{thresh} \left(w_{target} - w_{wilt}\right) + w_{wilt}

where :math:`w_{target}` is the irrigation target soil moisture (mm) 

.. math::
   :label: 25.63

   w_{target} = \sum_{j=1}^{N_{irr}} \theta_{target} \Delta z_{j} \ ,

:math:`w_{wilt}` is the wilting point soil moisture (mm) 

.. math::
   :label: 25.64

   w_{wilt} = \sum_{j=1}^{N_{irr}} \theta_{wilt} \Delta z_{j} \ ,

and :math:`f_{thresh}` is a tuning parameter.  The available moisture in 
the soil is 

.. math::
   :label: 25.65

   w_{avail} = \sum_{j=1}^{N_{irr}} \theta_{j} \Delta z_{j} \ ,

:math:`N_{irr}` is the index of the soil layer corresponding to a specified 
depth :math:`z_{irrig}` (:numref:`Table Irrigation parameters`) and 
:math:`\Delta z` is the thickness of the soil layer (section 
:numref:`Vertical Discretization`).  :math:`\theta_{j}` is the 
volumetric soil moisture in layer :math:`j` (section :numref:`Soil Water`).
:math:`\theta_{target}` and 
:math:`\theta_{wilt}` are the target and wilting point volumetric 
soil moisture values, respectively, and are determined by inverting 
:eq:`7.94` using soil matric 
potential parameters :math:`\Psi_{target}` and :math:`\Psi_{wilt}` 
(:numref:`Table Irrigation parameters`). After the soil moisture deficit 
:math:`D_{irrig}` is calculated, irrigation in an amount equal to 
:math:`\frac{D_{irrig}}{T_{irrig}}` (mm/s) is applied uniformly over 
the irrigation period :math:`T_{irrig}` (s).  Irrigation water is applied
directly to the ground surface, bypassing canopy interception (i.e.,
added to  :math:`{q}_{grnd,liq}`: section :numref:`Canopy Water`). 

To conserve mass, irrigation is removed from river water storage (Chapter 11).  
When river water storage is inadequate to meet irrigation demand, 
there are two options: 1) the additional water can be removed from the 
ocean model, or 2) the irrigation demand can be reduced such that 
river water storage is maintained above a specified threshold.  

.. _Table Irrigation parameters:

.. table:: Irrigation parameters

 +--------------------------------------+-------------+
 | Parameter                            |             |
 +======================================+=============+
 | :math:`f_{thresh}`                   |  1.0        |
 +--------------------------------------+-------------+
 | :math:`z_{irrig}`       (m)          |  0.6        |
 +--------------------------------------+-------------+
 | :math:`\Psi_{target}`   (mm)         | -3400       |
 +--------------------------------------+-------------+
 | :math:`\Psi_{wilt}`     (mm)         | -150000     |
 +--------------------------------------+-------------+

.. add a reference to surface data in chapter2
  To accomplish this we downloaded
  data of percent irrigated and percent rainfed corn, soybean, and
  temperate cereals (wheat, barley, and rye) (:ref:`Portmann et al. 2010 <Portmannetal2010>`),
  available online from
  *ftp://ftp.rz.uni-frankfurt.de/pub/uni-frankfurt/physische\_geographie/hydrologie/public/data/MIRCA2000/harvested\_area\_grids.*



.. _The details about what is new in CLM4.5:

The details about what is new in CLM4.5
--------------------------------------------

.. _Interactive irrigation for corn, temperate cereals, and soybean:

Interactive irrigation for corn, temperate cereals, and soybean
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

CLM4.0 included interactive irrigation only for the generic C3 crops,
i.e. plant functional types (pfts) 15 (rainfed) and 16 (irrigated) in
the CLM list of pfts and not for the additional crops of the interactive
crop management model (CROP). Irrigation and CROP were mutually
exclusive in CLM4.0.

In CLM4.5 we have reversed this situation. Now the irrigation model can
be used only while running with CROP. To accomplish this we downloaded
data of percent irrigated and percent rainfed corn, soybean, and
temperate cereals (wheat, barley, and rye) (:ref:`Portmann et al. 2010 <Portmannetal2010>`),
available online from

*ftp://ftp.rz.uni-frankfurt.de/pub/uni-frankfurt/physische\_geographie/hydrologie/public/data/MIRCA2000/harvested\_area\_grids.*

We embedded this data in CLM’s high-resolution pft data for use with the
tool mksurfdat to generate surface datasets at any desired resolution.
Now this data includes percent cover for 24 pfts:

1-16 as in the standard list of pfts, plus six more:

17 corn

18 irrigated\_corn

19 spring\_temperate\_cereal

20 irrigated\_spring\_temperate\_cereal

21 winter\_temperate\_cereal

22 irrigated\_winter\_temperate\_cereal

23 soybean

24 irrigated\_soybean

We intend surface datasets with 24 pfts only for CROP simulations with
or without irrigation. In simulations without irrigation, the rainfed
and irrigated crops merge into just rainfed crops at run time. Surface
datasets with 16 pfts can be used for all other CLM simulations.

.. _Interactive fertilization:

Interactive fertilization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

CLM adds nitrogen directly to the soil mineral nitrogen pool to meet
crop nitrogen demands. CLM’s separate crop land unit ensures that
natural vegetation will not access the fertilizer applied to crops.
Fertilizer in CLM5BGCCROP is prescribed by crop function types spatially
for each year based on the LUMIP land use and land cover change
time series (LUH2 for historical and SSPs for future) (:ref:`Lawrence et al. 2016 <Lawrenceetal2016>`).
There are two fields that are used to prescribe industrial fertilizer.
On the surface data set the field CONST_FERTNITRO_CFT specifies the 
annual fertilizer application for a non-transient simulations in g N/m\ :sup:`2`/yr.
In the case of a transient simulation this is replaced by the landuse.timeseries
file with the field FERTNITRO_CFT which is also in g N/m\ :sup:`2`/yr.
The values for both of these fields come from the LUMIP time series for each year.
In addition to the industrial fertilizer there is a background manure fertilizer
on the clm parameters file with the field manunitro. For the current CLM5BGCCROP,
this is set to 0.002 kg N/m\ :sup:`2`/yr. Since CLM’s denitrification rate is high
and results in a 50% loss of the unused available nitrogen each day,
fertilizer is applied slowly to minimize the loss and maximize plant
uptake. Fertilizer application begins during the emergence phase of crop
development and continues for 20 days, which helps reduce large losses
of nitrogen from leaching and denitrification during the early stage of
crop development. The 20-day period is chosen as an optimization to
limit fertilizer application to the emergence stage. A fertilizer
counter in seconds, *f*, is set as soon as the onset growth for crops
initiates:

.. math::
   :label: 25.18

    f = n \times 86400 

where *n* is set to 20 fertilizer application days. When the crop enters
phase 2 (leaf emergence to the beginning of grain fill) of its growth
cycle, fertilizer application begins by initializing fertilizer amount
to the total fertilizer at each grid cell divided by the initialized *f*.
Fertilizer is applied and *f* is decremented each time step until a zero balance on
the counter is reached.


.. _Biological nitrogen fixation for soybeans:

Biological nitrogen fixation for soybeans
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Biological N fixation for soybeans is calculated by the fixation and 
uptake of nitrogen module [add reference to chapter 18]. Unlike natural 
vegetation, where a fraction of the vegetation are N fixers, all soybeans 
are treated as N fixers.   

.. _Modified C\:N ratios for crops:

Modified C:N ratios for crops
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Carbon to nitrogen ratios (C:N) for crops are calculated by the flexible C:N
module that is new to CLM5. 

In CLM5, the flexible C:N module allows leaf C:N to vary based
on residual N allocated to the leaf pool after the demands of other plant organs
are met. Grain C/N is similarly xxx...
 
In order to account for this change, two sets of C:N
ratios are established in CLM for the leaf, stem, and fine root of
crops. This modified C:N ratio approach accounts for the nitrogen
retranslocation that occurs during phase 3 of crop growth. Leaf and stem
(and root for temperate cereals) C:N ratios for phases 1 and 2 are lower
than measurements (Table 20.3) to allow excess nitrogen storage in plant
tissue. During grain fill (phase 3) of the crop growth cycle, the
nitrogen in the plant tissues is moved to a storage pool to fulfill
nitrogen demands of organ (reproductive pool) development, such that the
resulting C:N ratio of the plant tissue is reflective of measurements at
harvest. All C:N ratios were determined by calibration process, through
comparisons of model output versus observations of plant carbon
throughout the growth season.

.. _Nitrogen retranslocation for crops:

Nitrogen retranslocation for crops
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Nitrogen retranslocation in crops occurs when nitrogen that was used for
tissue growth of leaves, stems, and fine roots during the early growth
season is remobilized and used for grain development (Pollmer et al.
1979; Crawford et al. 1982; Simpson et al. 1983; Ta and Weiland 1992;
Barbottin et al. 2005; Gallais et al. 2006, 2007). Nitrogen allocation
for crops follows that of natural vegetation, is supplied in CLM by the
soil mineral nitrogen pool, and depends on C:N ratios for leaves, stems,
roots, and organs. Nitrogen demand during organ development is fulfilled
through retranslocation from leaves, stems, and roots. Nitrogen
retranslocation is initiated at the beginning of the grain fill stage
for all crops except soybean, for which retranslocation is after LAI decline. 
Nitrogen stored in the leaf and stem is moved into a storage
retranslocation pool. For wheat and rice, nitrogen in roots is also
released into the retranslocation storage pool. The quantity of nitrogen
mobilized depends on the C:N ratio of the plant tissue, and is
calculated as

.. math::
   :label: 25.14

   leaf\_ to\_ retransn=n_{leaf} -\frac{c_{leaf} }{CN_{leaf}^{f} }

.. math::
   :label: 25.15

   stemn\_ to\_ retransn=n_{stem} -\frac{c_{stem} }{CN_{stem}^{f} }

.. math::
   :label: 25.16

   frootn\_ to\_ retransn=n_{froot} -\frac{c_{froot} }{CN_{froot}^{f} }

where :math:`{C}_{leaf}`, :math:`{C}_{stem}`, and :math:`{C}_{froot}` is the carbon in the plant leaf, stem, and fine
root, respectively, :math:`{N}_{leaf}`, :math:`{N}_{stem}`, and :math:`{N}_{froot}` 
is the nitrogen in the plant leaf, stem, and fine root, respectively, and :math:`CN^f_{leaf}`,
:math:`CN^f_{stem}`, and :math:`CN^f_{froot}` is the post-grain fill C:N
ratio of the leaf, stem, and fine root respectively (:numref:`Table Pre- and post-grain fill CN ratios`). Since
C:N measurements are taken from mature crops, pre-grain development C:N
ratios for leaves, stems, and roots are optimized to allow maximum
nitrogen accumulation for later use during organ development. Post-grain
fill C:N ratios are assigned the same as crop residue. Once excess
nitrogen is moved into the retranslocated pool, during the remainder of
the growing season the retranslocated pool is used first to meet plant
nitrogen demand by assigning the available nitrogen from the
retranslocated pool equal to the plant nitrogen demand. Once the
retranslocation pool is depleted, soil mineral nitrogen pool is used to
fulfill plant nitrogen demands.

.. _Table Pre- and post-grain fill CN ratios:

.. table:: Pre- and post-grain fill C:N ratios for crop leaf, stem, fine root, and reproductive pools.

 +----------------------------+--------+---------------------+-----------+
 | Pre-grain fill stage       | Corn   | Temperate Cereals   | Soybean   |
 +============================+========+=====================+===========+
 | :math:`{CN}_{leaf}`        | 10     | 15                  | 25        |
 +----------------------------+--------+---------------------+-----------+
 | :math:`{CN}_{stem}`        | 50     | 50                  | 50        |
 +----------------------------+--------+---------------------+-----------+
 | :math:`{CN}_{froot}`       | 42     | 30                  | 42        |
 +----------------------------+--------+---------------------+-----------+
 | Post-grain fill stage      |        |                     |           |
 +----------------------------+--------+---------------------+-----------+
 | :math:`CN_{leaf}^{f}`      | 65     | 65                  | 65        |
 +----------------------------+--------+---------------------+-----------+
 | :math:`CN_{stem}^{f}`      | 120    | 100                 | 130       |
 +----------------------------+--------+---------------------+-----------+
 | :math:`CN_{froot}^{f}`     | 42     | 40                  | 42        |
 +----------------------------+--------+---------------------+-----------+
 | :math:`CN_{repr}^{f}`      | 50     | 40                  | 60        |
 +----------------------------+--------+---------------------+-----------+

.. _Separate reproductive pool:

Separate reproductive pool
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

One notable difference between natural vegetation and crops is the
presence of a reproductive carbon pool (and nitrogen pool). Accounting
for the reproductive pool helps determine whether crops are performing
reasonably, through yield calculations, seasonal GPP and NEE changes,
etc. The reproductive pool is maintained similarly to the leaf, stem,
and fine root pools, but allocation of carbon and nitrogen does not
begin until the grain fill stage of crop development. Eq. shows the
carbon and nitrogen allocation coefficients to the reproductive pool. In
the CLM4.0, allocation of carbon to the reproductive pool was calculated
but merged with the stem pool. In the model, as allocation declines
during the grain fill stage of growth, increasing amounts of carbon and
nitrogen are available for grain development.

.. _Latitude vary base tempereature for growing degree days:

Latitude vary base tempereature for growing degree days
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For both rainfed and irrigated spring wheat and sugarcane, 
a latitude vary base temperature in calculating :math:`GDD_{T_{{\rm 2m}} }` 
(growing degree days since planting) was introduced.  

.. math::
   :label: 25.17

   latitude\ vary\ baset = \left\{
   \begin{array}{lr}    
   baset +12 - 0.4 \times latitude &\qquad 0 \le latitude \le 30 \\
   baset +12 + 0.4 \times latitude &\qquad -30 \le latitude \le 0    
   \end{array} \right\}

where :math:`baset` is the 5\ :sup:`th` column in :numref:`Table Crop plant functional types`.
Such latitude vary baset could increase the base temperature, slow down :math:`GDD_{T_{{\rm 2m}} }` 
accumulation, and extend the growing season for -30º to 30º regions for spring wheat 
and sugarcane. 
