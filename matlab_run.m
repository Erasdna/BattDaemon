%Absolute path!!!!
jlcall('', ...
     'project', '/data2/andreas/BattDaemon/Julia_run', ... % activate a local Julia Project
     'setup', '/data2/andreas/BattDaemon/setup.jl',...
     'modules', {'Julia_run', 'JSON'}, ... % load a custom module and some modules from Base Julia
     'threads', 'auto', ... % use the default number of Julia threads
     'restart', true ... % start a fresh Julia server environment
     )
%% Import the required modules from MRST
% load MRST modules
mrstModule add ad-core mrst-gui mpfa agmg linearsolvers

%% Setup the properties of Li-ion battery materials and cell design
% The properties and parameters of the battery cell, including the
% architecture and materials, are set using an instance of
% :class:`BatteryInputParams <Battery.BatteryInputParams>`. This class is
% used to initialize the simulation and it propagates all the parameters
% throughout the submodels. The input parameters can be set manually or
% provided in json format. All the parameters for the model are stored in
% the paramobj object.

jsonstruct = parseBattmoJson(fullfile('ParameterData','BatteryCellParameters','LithiumIonBatteryCell','lithium_ion_battery_nmc_graphite.json'));

% We define some shorthand names for simplicity.
ne      = 'NegativeElectrode';
pe      = 'PositiveElectrode';
elyte   = 'Electrolyte';
thermal = 'ThermalModel';
am      = 'ActiveMaterial';
itf     = 'Interface';
sd      = 'SolidDiffusion';
ctrl    = 'Control';
cc      = 'CurrentCollector';

jsonstruct.use_thermal = false;
jsonstruct.include_current_collectors = false;

jsonstruct.(pe).(am).diffusionModelType = 'full';
jsonstruct.(ne).(am).diffusionModelType = 'full';

paramobj = BatteryInputParams(jsonstruct);

paramobj.(ne).(am).InterDiffusionCoefficient = 0;
paramobj.(pe).(am).InterDiffusionCoefficient = 0;

% paramobj.(ne).(am).(sd).N = 5;
% paramobj.(pe).(am).(sd).N = 5;

paramobj = paramobj.validateInputParams();

use_cccv = false;
if use_cccv
    cccvstruct = struct( 'controlPolicy'     , 'CCCV',  ...
                         'initialControl'    , 'discharging', ...
                         'CRate'             , 1         , ...
                         'lowerCutoffVoltage', 2.4       , ...
                         'upperCutoffVoltage', 4.1       , ...
                         'dIdtLimit'         , 0.01      , ...
                         'dEdtLimit'         , 0.01);
    cccvparamobj = CcCvControlModelInputParams(cccvstruct);
    paramobj.Control = cccvparamobj;
end

%% Setup the geometry and computational mesh
% Here, we setup the 1D computational mesh that will be used for the
% simulation. The required discretization parameters are already included
% in the class BatteryGenerator1D. 
gen = BatteryGenerator1D();

% Now, we update the paramobj with the properties of the mesh. 
paramobj = gen.updateBatteryInputParams(paramobj);

output=jlcall('Julia_run.jsondict', {paramobj})

a=1
