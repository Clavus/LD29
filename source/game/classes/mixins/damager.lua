
local Damager = {}

function Damager:initialize( d, s )

	self._damage = d or 0
	self._slowdownfactor = s or 1
	
end

function Damager:setSlowdownFactor( x )
	
	self._slowdownfactor = x
	
end

function Damager:setDamageOnImpact( x )

	self._damage = x

end

function Damager:getSlowdownFactor()

	return self._slowdownfactor
	
end

function Damager:getDamage()

	return self._damage
	
end

return Damager