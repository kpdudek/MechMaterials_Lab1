function Mechanics_of_Materials_Lab1
if fopen('steel_time.mat') == -1
    [steel_time,steel_force,steel_delta] = read_csv('Steel.csv');
    [Aluminum_time,Aluminum_force,Aluminum_delta] = read_csv('Aluminum.csv');
    [Acrylic_time,Acrylic_force,Acrylic_delta] = read_csv('Acrylic.csv');
    [Copper_time,Copper_force,Copper_delta] = read_csv('Copper.csv');
    save('Data.mat')
else
    load('Data.mat')
end

A_S =  4.2742*10^-5;
A_Al = 4.04838*10^-5;
A_Ac = 3.80554*10^-5;
A_C = 4.28225*10^-5;

%%%% FORCE vs EXTENSION %%%%
% plot_force_extension(steel_force,steel_delta,'Steel')
% plot_force_extension(Aluminum_force,Aluminum_delta,'Aluminum')
% plot_force_extension(Acrylic_force,Acrylic_delta,'Acrylic')
% plot_force_extension(Copper_force,Copper_delta,'Copper')

%%%% STRESS vs STRAIN %%%%
[S_stress,S_strain] = compute_StressStrain(steel_force,steel_delta,A_S,'Steel');
[Al_stress,Al_strain] = compute_StressStrain(Aluminum_force,Aluminum_delta,A_Al,'Aluminum');
[Ac_stress,Ac_strain] = compute_StressStrain(Acrylic_force,Acrylic_delta,A_Ac,'Acrylic');
[C_stress,C_strain] = compute_StressStrain(Copper_force,Copper_delta,A_C,'Copper');

%%%% LINEAR FITS %%%%
lin_S = linear_regime(S_stress,S_strain,807,320,'Steel');
lin_Al = linear_regime(Al_stress,Al_strain,1605,1160,'Aluminum');
lin_Ac = linear_regime(Ac_stress,Ac_strain,1501,1501,'Acrylic');
lin_C = linear_regime(C_stress,C_strain,551,243,'Copper');

%%%% GROUP PLOT %%%%
figure('Visible','on','Name','Group PLot')
plot(S_strain,S_stress,'.',Al_strain,Al_stress,'.',Ac_strain,Ac_stress,'.',C_strain,C_stress,'.','MarkerSize',8)
xlabel('Strain(\DeltaL/L_o')
ylabel('Stress(MPa)')
title('Stress Strain Curves for all Materials')
legend('Steel','Aluminum','Acrylic','Copper')
xlim([-.005 max([max(S_strain),max(Al_strain),max(C_strain)])*1.05])


%%%% FUNCTION DEFINITIONS %%%%
function [time,force,delta] = read_csv(file)
fid = fopen(file,'r');
force = [];
delta = [];
time = [];
counter = 1;

while ~feof(fid)
    if counter < 2
        line = fgetl(fid);
        counter = counter + 1;
    else
        line = fgetl(fid);
        
        [t,remain] = strtok(line,',');
        [elap,remain] = strtok(remain,',');
        [cycle,remain] = strtok(remain,',');
        [elap_cyc,remain] = strtok(remain,',');
        [step,remain] = strtok(remain,',');
        [tot_cyc,remain] = strtok(remain,',');
        [pos,remain] = strtok(remain,',');
        [load,remain] = strtok(remain,',');
        exten = erase(remain,',');
        
        force(end+1) = str2double(load);
        delta(end+1) = str2double(exten);
        time(end+1) = str2double(t);
    end
end
fclose(fid);

function plot_force_extension(force,exten,material)
title1 = sprintf('Force vs Extension for %s',material);
figure('Visible','on','Name',title1)
plot(exten,force,'.','MarkerSize',7)
title(title1)
xlabel('Extension(mm)')
ylabel('Force(kN)')
xlim([0 max(exten)*1.05])

function [stress,strain] = compute_StressStrain(force,displacement,area,material)
l = 80;
stress = [];
strain = [];
for i = 1:length(force)
    stress = [stress,((force(i)*1000)/area)*10^-6];
    strain = [strain,displacement(i)/l];
end

title1 = sprintf('Stress vs Strain for %s',material);
figure('Visible','on','Name',title1)
plot(strain,stress,'.','MarkerSize',7)
title(title1)
ylabel('Stress(MPa)')
xlabel('Strain (\DeltaL/L_o')
xlim([-.0025 max(strain)*1.05])

function lin_fit = linear_regime(stress,strain,cutoff,lin,material)
stress = stress(1:cutoff);
strain = strain(1:cutoff);

lin_stress = stress(1:lin);
lin_strain = strain(1:lin);

lin_fit = fitlm(lin_strain,lin_stress,'linear');
q=table2array(lin_fit.Coefficients(1,'Estimate'));
p=table2array(lin_fit.Coefficients(2,'Estimate'));
%plot(t,omega.*p+q,'b',t,rpm,'r')
linfit = lin_strain.*p+q;
percent = lin_strain+.002;

rsq = lin_fit.Rsquared.Ordinary;
fprintf('RSquared for %s is %f\n',material,rsq)

title1 = sprintf('Linear Fit and .2 Offset for %s',material);
figure('Visible','on','Name',title1)
plot(strain,stress,'.',lin_strain,linfit,percent,linfit,'LineWidth',2,'MarkerSize',8)
linear = sprintf('Linear Fit, E = %.2f',p);
title(title1)
xlabel('Strain(\DeltaL/L_o)')
ylabel('Stress(MPa)')
legend('Data',linear,'.2% Offset','Location','Southeast')
xlim([-.0005 max(strain)*1.05])











