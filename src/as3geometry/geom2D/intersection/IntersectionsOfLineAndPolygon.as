package as3geometry.geom2D.intersection 
{
	import as3geometry.geom2D.Line;
	import as3geometry.geom2D.LineType;
	import as3geometry.geom2D.Polygon;
	import as3geometry.geom2D.Vertex;
	import as3geometry.geom2D.immutable.ImmutableLine;
	import as3geometry.geom2D.mutable.Mutable;
	import as3geometry.geom2D.mutable.MutableVertex;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	/**
	 * 
	 * 
	 * (c) 2009 alecmce.com
	 *
	 * @author Alec McEachran
	 */
	public class IntersectionsOfLineAndPolygon implements Mutable 
	{

		private var _polygon:Polygon;
		
		private var _line:Line;
		
		private var _potential:Vector.<IntersectionOfTwoLinesVertex>;
		
		private var _actual:Vector.<MutableVertex>;
		
		private var _changed:ISignal;
		
		private var _invalidated:Boolean;
		
		public function IntersectionsOfLineAndPolygon(polygon:Polygon, line:Line)
		{
			_polygon = polygon;
			if (_polygon is Mutable)
				Mutable(_polygon).changed.add(onDefinienChanged);
			
			_line = line;
			if (_line is Mutable)
				Mutable(_line).changed.add(onDefinienChanged);

			_potential = calculateVertices();
			
			_changed = new Signal(this, Mutable);
			_invalidated = false;
			
			_actual = generateActuals();
			resolveActuals();
		}
		
		private function onDefinienChanged(mutable:Mutable):void
		{
			_invalidated = true;
			_changed.dispatch(mutable);
		}
		
		public function get potentialIntersections():Vector.<Vertex>
		{
			return Vector.<Vertex>(_potential);
		}

		public function get actualIntersections():Vector.<Vertex>
		{
			if (_invalidated)
				update();
			
			return Vector.<Vertex>(_actual);
		}
		
		public function get changed():ISignal
		{
			return _changed;
		}
		
		private function update():void
		{
			_invalidated = false;
			resolveActuals();
		}
		
		private function calculateVertices():Vector.<IntersectionOfTwoLinesVertex>
		{
			var count:int = _polygon.count;
			var vertices:Vector.<IntersectionOfTwoLinesVertex> = new Vector.<IntersectionOfTwoLinesVertex>(count, true);
			
			var b:Vertex = _polygon.get(count - 1);
			for (var i:int = 0; i < count; i++)
			{
				var a:Vertex = _polygon.get(i);
				var edge:ImmutableLine = new ImmutableLine(a, b, LineType.SEGMENT);
				var vertex:IntersectionOfTwoLinesVertex = new IntersectionOfTwoLinesVertex(edge, _line);
				b = a;
				
				vertices[i] = vertex;
			}
			
			return vertices;
		}
		
		private function generateActuals():Vector.<MutableVertex>
		{
			var n:int = _potential.length;
			var actuals:Vector.<MutableVertex> = new Vector.<MutableVertex>(n, true);
			
			while (--n > -1)
				actuals[n] = new MutableVertex(Number.NaN, Number.NaN);
				
			return actuals;
		}
		
		private function resolveActuals():void
		{
			var sorted:Vector.<IntersectionOfTwoLinesVertex> = _potential.sort(sortByMultipliers);
			
			var len:int = _potential.length;
			var nullify:Boolean = false;
			for (var i:int = 0; i < len; i++)
			{
				var a:MutableVertex = _actual[i];
				
				p = sorted[i];
				trace(p.x, p.y);
				
				if (!nullify)
				{
					var p:IntersectionOfTwoLinesVertex = sorted[i];
					nullify = isNaN(p.x);
				}
				
				if (nullify)
					a.set(Number.NaN, Number.NaN);
				else
					a.set(p.x, p.y);
			}
		}
		
		private function sortByMultipliers(a:IntersectionOfTwoLinesVertex, b:IntersectionOfTwoLinesVertex):int
		{
			var aN:Number = a.bMultiplier;
			
			var isAInvalid:Boolean = isNaN(aN);
			var isBInvalid:Boolean = isNaN(bN);
			
			if (isAInvalid && isBInvalid)
				return 0;
			else if (isAInvalid)
				return 1;
			else if (isBInvalid)
				return -1;
			if (aN < bN)
				return -1;
			else if (aN > bN)
				return 1;
			
			return 0;
		}
		
	}
}