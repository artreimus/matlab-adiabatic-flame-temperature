function calculateAdiabaticFlameTemp
    format long g;

    disp("Hi! You are now running the program that will solve for the Adiabatic Flame Temperature");
    disp("Please input all the required information to starting solving");
    
    %% PROMPT USER
    prompt = "What is the chemical type (0 = n-Pentane; 1 = Propane; 2 = 1-Heptene; 3 = Cyclohexane; 4 = 1-Pentene): ";
    chemicalType = input(prompt);

    if chemicalType < 0 || chemicalType >= 5
        ME = MException('MyComponent:emptyVariable', 'Invalid chemical value. Please only input 0-4');
        throw(ME);
    end

    prompt = "How many moles (mol/s): ";
    chemicalNumMoles = input(prompt);

    prompt = "What is the temperature (Degree Celsius): ";
    temperature = input(prompt);
    temperature = temperature + 273.15;

    prompt = "How many bars: ";
    bars = input(prompt);

    prompt = "What is the excess air %: ";
    excess = input(prompt);
    excess = excess / 100;

    if chemicalNumMoles < 0 || temperature < 0 || bars < 0 || excess < 0
        ME = MException('MyComponent:emptyVariable', 'Input cannot be negative');
        throw(ME);
    end

    if isempty(chemicalType) || isempty(temperature) || isempty(bars) || isempty(excess)
        ME = MException('MyComponent:emptyVariable', 'Please provide all required fields');
        throw(ME);
    end

    %% DEBUG
%     chemicalType = 1;
%     chemicalNumMoles = 100;
%     temperature = 25;
%     bars = 1;
%     excess = 20 / 100;

   
    % STANDARD ENTHALPHY OF THE CHEMICALS
    standardEnthalphyNPentane = -146.76;
    standardEnthalphyPropane = -104.68;
    standardEntalphy1Heptane = -62.76;
    standardEntalphyCyclohexane = -123.14;
    standardEntalphy1Pentene = -21.28;

    % STANDARD ENTHALPHY OF C02 and H20
    standardEntalphyCO2 = -393.522;
    standardenthalphyH20 = -241.826;

    % MOLECULAR WEIGHT
    mWeightC02 = 0.044;
    mWeightH20 = 0.018;
    mWeight02 = 0.032;
    mWeightN2 = 0.028;

    % a
    a1 = -14.16;
    a2 = -8.29;
    a3 = -2.742;
    a4 = -10.02;

    % b
    b1 = -0.001736;
    b2 = 0.0005693;
    b3 = -0.0003969;
    b4 = -0.0008984;

    % c
    c1 = 298;
    c2 = 629.4;
    c3 = 151.1;
    c4 = 629;

    % d
    d1 = 3.182;
    d2 = 1.767;
    d3 = 1.03;
    d4 = 2.051;

    % NUM OF MOLES
    airNitrogenRatio = 79;
    airOxygenRatio = 21;

    numOfMolesC02 = 0;
    numOfMolesH20  = 0;
    numOfMoles02 = 0;
    
    standardEnthalphyChemical = 0;

    % BALANCE COMBUSTION EQUATION
    numPropane = 0;
    numOxygen = 0;

    if chemicalType == 0
        chemicalType = "n-Pentane";
        numOfMolesC02 = 5;
        numOfMolesH20  = 12;
        numOfMoles02 = 2;
        standardEnthalphyChemical = standardEnthalphyNPentane;
        numPropane = 1;
        numOxygen = 8;
    elseif chemicalType == 1
        chemicalType = "Propane";
        numOfMolesC02 = 3;
        numOfMolesH20  = 8;
        numOfMoles02 = 2;
        standardEnthalphyChemical = standardEnthalphyPropane;
        numPropane = 1;
        numOxygen = 5;
    elseif chemicalType == 2
        chemicalType = "1-Heptane";
        numOfMolesC02 = 7;
        numOfMolesH20  = 14;
        numOfMoles02 = 2;
        standardEnthalphyChemical = standardEntalphy1Heptane;
        numPropane = 1;
        numOxygen = 11;
    elseif chemicalType == 3
        chemicalType = "Cyclohexane";
        numOfMolesC02 = 6;
        numOfMolesH20  = 12;
        numOfMoles02 = 2;
        numPropane = 1;
        numOxygen = 9;
        standardEnthalphyChemical = standardEntalphyCyclohexane;
    elseif chemicalType == 4
        chemicalType = "1-Pentene";
        numOfMolesC02 = 5;
        numOfMolesH20  = 10;
        numOfMoles02 = 2;
        standardEnthalphyChemical = standardEntalphy1Pentene;
        numPropane = 1;
        numOxygen = 7;
    end
    
    fprintf("Chemical Type: ")
    disp(chemicalType);
    fprintf("Num of Moles (mol/s): ")
    disp(chemicalNumMoles);
    fprintf("Standrd Enthalphy of the Chemical (kJ/mol): ")
    disp(standardEnthalphyChemical);
    fprintf("Temperature (Kelvin): ")
    disp(temperature);
    fprintf("Bars: ")
    disp(bars);
    fprintf("Excess (in Decimal): ")
    disp(excess);
   
    %% MATERIAL BALANCE
    no2Theo = chemicalNumMoles*(numOxygen/numPropane);
    no2Fed = excess * no2Theo + no2Theo;
    n2Fed = no2Fed * (airNitrogenRatio / airOxygenRatio);
    
    fprintf("NO2Theo (mol O2): ")
    disp(no2Theo);
  
    fprintf("NO2FED (mol O2): ")
    disp(no2Fed);

    fprintf("N2FED (mol N2): ")
    disp(n2Fed);
    
    %% ELEMENTAL BALANCE
    elemBalC02 = 100 * numOfMolesC02;
    elemBalH20 = 100 * (numOfMolesH20 / 2);
    elemBal02 = ((numOfMoles02 * no2Fed) - (2 * elemBalC02) - elemBalH20) / 2;
    elemBalN2 = n2Fed;

    fprintf("C02 Balance (mol C02): ")
    disp(elemBalC02);

    fprintf("H20 Balance (mol H20): ")
    disp(elemBalH20);

    fprintf("02 Balance (mol 02): ")
    disp(elemBal02);

    fprintf("N2 Balance (mol N2): ")
    disp(elemBalN2);

    %% Solving for LHS, RHS, and ADT

    leftHandSideEquation = (chemicalNumMoles * standardEnthalphyChemical) - (elemBalC02 * standardEntalphyCO2) - (elemBalH20 * standardenthalphyH20);

    adiabaticFlameTemperature = 0;

    % delta H
    delta1 = ((a1 * (adiabaticFlameTemperature - temperature)) + (b1/2 * (adiabaticFlameTemperature - temperature)^2) + (c1/3 * (adiabaticFlameTemperature - temperature)^3) + (d1/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightC02;
    delta2 = ((a2 * (adiabaticFlameTemperature - temperature)) + (b2/2 * (adiabaticFlameTemperature - temperature)^2) + (c2/3 * (adiabaticFlameTemperature - temperature)^3) + (d2/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightH20;
    delta3 = ((a3 * (adiabaticFlameTemperature - temperature)) + (b3/2 * (adiabaticFlameTemperature - temperature)^2) + (c3/3 * (adiabaticFlameTemperature - temperature)^3) + (d3/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeight02;
    delta4 = ((a4 * (adiabaticFlameTemperature - temperature)) + (b4/2 * (adiabaticFlameTemperature - temperature)^2) + (c4/3 * (adiabaticFlameTemperature - temperature)^3) + (d4/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightN2;
    
    rightHandSideEquation = (delta1*elemBalC02) + (delta2*elemBalH20) + (delta3*elemBal02) + (delta4*elemBalN2);

    while(leftHandSideEquation > rightHandSideEquation)
        adiabaticFlameTemperature = adiabaticFlameTemperature + 1;
        delta1 = ((a1 * (adiabaticFlameTemperature - temperature)) + (b1/2 * (adiabaticFlameTemperature - temperature)^2) + (c1/3 * (adiabaticFlameTemperature - temperature)^3) + (d1/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightC02;
        delta2 = ((a2 * (adiabaticFlameTemperature - temperature)) + (b2/2 * (adiabaticFlameTemperature - temperature)^2) + (c2/3 * (adiabaticFlameTemperature - temperature)^3) + (d2/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightH20;
        delta3 = ((a3 * (adiabaticFlameTemperature - temperature)) + (b3/2 * (adiabaticFlameTemperature - temperature)^2) + (c3/3 * (adiabaticFlameTemperature - temperature)^3) + (d3/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeight02;
        delta4 = ((a4 * (adiabaticFlameTemperature - temperature)) + (b4/2 * (adiabaticFlameTemperature - temperature)^2) + (c4/3 * (adiabaticFlameTemperature - temperature)^3) + (d4/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightN2;
        rightHandSideEquation = (delta1*elemBalC02) + (delta2*elemBalH20) + (delta3*elemBal02) + (delta4*elemBalN2);
    end

    while(leftHandSideEquation < rightHandSideEquation)
        adiabaticFlameTemperature = adiabaticFlameTemperature - 1;
        delta1 = ((a1 * (adiabaticFlameTemperature - temperature)) + (b1/2 * (adiabaticFlameTemperature - temperature)^2) + (c1/3 * (adiabaticFlameTemperature - temperature)^3) + (d1/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightC02;
        delta2 = ((a2 * (adiabaticFlameTemperature - temperature)) + (b2/2 * (adiabaticFlameTemperature - temperature)^2) + (c2/3 * (adiabaticFlameTemperature - temperature)^3) + (d2/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightH20;
        delta3 = ((a3 * (adiabaticFlameTemperature - temperature)) + (b3/2 * (adiabaticFlameTemperature - temperature)^2) + (c3/3 * (adiabaticFlameTemperature - temperature)^3) + (d3/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeight02;
        delta4 = ((a4 * (adiabaticFlameTemperature - temperature)) + (b4/2 * (adiabaticFlameTemperature - temperature)^2) + (c4/3 * (adiabaticFlameTemperature - temperature)^3) + (d4/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightN2;
        rightHandSideEquation = (delta1*elemBalC02) + (delta2*elemBalH20) + (delta3*elemBal02) + (delta4*elemBalN2);
    end

    if((leftHandSideEquation - rightHandSideEquation) > -0.0001)
        while(leftHandSideEquation > rightHandSideEquation)
            adiabaticFlameTemperature = adiabaticFlameTemperature + 0.00001;
            delta1 = ((a1 * (adiabaticFlameTemperature - temperature)) + (b1/2 * (adiabaticFlameTemperature - temperature)^2) + (c1/3 * (adiabaticFlameTemperature - temperature)^3) + (d1/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightC02;
            delta2 = ((a2 * (adiabaticFlameTemperature - temperature)) + (b2/2 * (adiabaticFlameTemperature - temperature)^2) + (c2/3 * (adiabaticFlameTemperature - temperature)^3) + (d2/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightH20;
            delta3 = ((a3 * (adiabaticFlameTemperature - temperature)) + (b3/2 * (adiabaticFlameTemperature - temperature)^2) + (c3/3 * (adiabaticFlameTemperature - temperature)^3) + (d3/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeight02;
            delta4 = ((a4 * (adiabaticFlameTemperature - temperature)) + (b4/2 * (adiabaticFlameTemperature - temperature)^2) + (c4/3 * (adiabaticFlameTemperature - temperature)^3) + (d4/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightN2;
            rightHandSideEquation = (delta1*elemBalC02) + (delta2*elemBalH20) + (delta3*elemBal02) + (delta4*elemBalN2);
        end
        
        while(leftHandSideEquation < rightHandSideEquation)
            adiabaticFlameTemperature = adiabaticFlameTemperature - 0.000001;
            delta1 = ((a1 * (adiabaticFlameTemperature - temperature)) + (b1/2 * (adiabaticFlameTemperature - temperature)^2) + (c1/3 * (adiabaticFlameTemperature - temperature)^3) + (d1/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightC02;
            delta2 = ((a2 * (adiabaticFlameTemperature - temperature)) + (b2/2 * (adiabaticFlameTemperature - temperature)^2) + (c2/3 * (adiabaticFlameTemperature - temperature)^3) + (d2/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightH20;
            delta3 = ((a3 * (adiabaticFlameTemperature - temperature)) + (b3/2 * (adiabaticFlameTemperature - temperature)^2) + (c3/3 * (adiabaticFlameTemperature - temperature)^3) + (d3/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeight02;
            delta4 = ((a4 * (adiabaticFlameTemperature - temperature)) + (b4/2 * (adiabaticFlameTemperature - temperature)^2) + (c4/3 * (adiabaticFlameTemperature - temperature)^3) + (d4/4 * (adiabaticFlameTemperature-temperature)^4)) * mWeightN2;            rightHandSideEquation = (delta1*elemBalC02) + (delta2*elemBalH20) + (delta3*elemBal02) + (delta4*elemBalN2);
        end
    end
    
    fprintf("Delta 1 (kJ/mol): ")
    disp(delta1);

    fprintf("Delta 2 (kJ/mol): ")
    disp(delta2);

    fprintf("Delta 3 (kJ/mol): ")
    disp(delta3);

    fprintf("Delta 4 (kJ/mol): ")
    disp(delta4);

    fprintf("Left Hand Side of the Equation (kJ): ")
    disp(leftHandSideEquation);

    fprintf("Right Hand Side of the Equation (kJ): ")
    disp(rightHandSideEquation);

    fprintf("Adiabatic Flame Temperature (Kelvin): ")
    disp(adiabaticFlameTemperature);
    
end